import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/visit.dart';
import '../../../services/visits_service.dart';
import '../../../services/activities_service.dart';
import '../../../services/offline_storage_service.dart';

class VisitsController extends GetxController {
  final VisitsService _visitsService = Get.find<VisitsService>();
  final ActivitiesService _activitiesService = Get.find<ActivitiesService>();
  final OfflineStorageService _offlineStorage =
      Get.find<OfflineStorageService>();

  final visits = <Visit>[].obs;
  final filteredVisits = <Visit>[].obs;
  final isLoading = false.obs;
  final activities = <Map<String, dynamic>>[].obs;
  final hasPendingSync = false.obs;
  final syncProgress = 0.0.obs;
  final pendingVisits = <Visit>[].obs;
  final syncRetryCount = 0.obs;
  static const maxRetries = 3;

  // Search and filter properties
  final searchQuery = ''.obs;
  final selectedStatus = 'All'.obs;
  final selectedActivity = 'All'.obs;
  final dateRange = Rxn<DateTimeRange>();
  final dateRangeText = 'Select Date Range'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVisits();
    fetchActivities();
    _setupNetworkListener();
    _loadPendingVisits();
  }

  void _setupNetworkListener() {
    ever(_offlineStorage.isOnline, (bool online) {
      if (online) {
        syncPendingVisits();
      }
    });
  }

  Future<void> _loadPendingVisits() async {
    final pending = await _offlineStorage.getPendingVisits();
    pendingVisits.value = pending;
    hasPendingSync.value = pending.isNotEmpty;
  }

  Future<void> fetchVisits() async {
    isLoading.value = true;
    try {
      final fetchedVisits = await _visitsService.fetchVisits();
      visits.value = fetchedVisits;
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load visits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActivities() async {
    try {
      final fetchedActivities = await _activitiesService.fetchActivities();
      activities.value = fetchedActivities;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load activities: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> syncPendingVisits() async {
    if (!_offlineStorage.isOnline.value) return;

    try {
      hasPendingSync.value = true;
      syncProgress.value = 0.0;
      syncRetryCount.value = 0;

      final pending = await _offlineStorage.getPendingVisits();
      if (pending.isEmpty) {
        hasPendingSync.value = false;
        return;
      }

      final total = pending.length;
      var successCount = 0;

      for (var i = 0; i < pending.length; i++) {
        try {
          await _visitsService.createVisit(pending[i]);
          successCount++;
          syncProgress.value = successCount / total;
        } catch (e) {
          if (syncRetryCount.value < maxRetries) {
            syncRetryCount.value++;
            i--; // Retry the same visit
            await Future.delayed(
                const Duration(seconds: 2)); // Wait before retry
            continue;
          }
          throw Exception('Failed to sync visit after $maxRetries retries: $e');
        }
      }

      await _loadPendingVisits(); // Refresh pending visits list
      await fetchVisits(); // Refresh the main list
      hasPendingSync.value = false;
      syncProgress.value = 1.0;
      syncRetryCount.value = 0;

      Get.snackbar(
        'Success',
        'Visits synchronized successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      hasPendingSync.value = false;
      syncProgress.value = 0.0;
      Get.snackbar(
        'Error',
        'Failed to sync visits: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setStatusFilter(String? status) {
    if (status != null) {
      selectedStatus.value = status;
      applyFilters();
    }
  }

  void setActivityFilter(String? activityId) {
    if (activityId != null) {
      selectedActivity.value = activityId;
      applyFilters();
    }
  }

  Future<void> selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: dateRange.value,
    );

    if (picked != null) {
      dateRange.value = picked;
      dateRangeText.value =
          '${_formatDate(picked.start)} - ${_formatDate(picked.end)}';
      applyFilters();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'All';
    selectedActivity.value = 'All';
    dateRange.value = null;
    dateRangeText.value = 'Select Date Range';
    applyFilters();
  }

  void applyFilters() {
    var filtered = visits.toList();

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((visit) {
        return visit.customerName.toLowerCase().contains(query) ||
            visit.location.toLowerCase().contains(query) ||
            visit.notes.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'All') {
      filtered = filtered
          .where((visit) => visit.status == selectedStatus.value)
          .toList();
    }

    // Apply activity filter
    if (selectedActivity.value != 'All') {
      filtered = filtered
          .where(
              (visit) => visit.activitiesDone.contains(selectedActivity.value))
          .toList();
    }

    // Apply date range filter
    if (dateRange.value != null) {
      filtered = filtered.where((visit) {
        final visitDate = visit.visitDate;
        return visitDate.isAfter(
                dateRange.value!.start.subtract(const Duration(days: 1))) &&
            visitDate
                .isBefore(dateRange.value!.end.add(const Duration(days: 1)));
      }).toList();
    }

    filteredVisits.assignAll(filtered);
  }

  Map<String, int> getVisitStatistics() {
    final total = visits.length;
    final completed =
        visits.where((v) => v.status.toLowerCase() == 'completed').length;
    final pending =
        visits.where((v) => v.status.toLowerCase() == 'pending').length;
    final cancelled =
        visits.where((v) => v.status.toLowerCase() == 'cancelled').length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'cancelled': cancelled,
    };
  }
}

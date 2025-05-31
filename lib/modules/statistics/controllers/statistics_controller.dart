import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/visits_service.dart';
import 'package:logging/logging.dart';

class StatisticsController extends GetxController {
  final VisitsService _visitsService = Get.find<VisitsService>();
  final RxInt totalVisits = 0.obs;
  final RxInt completedVisits = 0.obs;
  final RxInt inProgressVisits = 0.obs;
  final RxInt cancelledVisits = 0.obs;
  final RxInt pendingVisits = 0.obs;
  final RxMap<String, int> monthlyStats = <String, int>{}.obs;
  final RxMap<String, int> statusDistribution = <String, int>{}.obs;
  final RxMap<String, int> activityCompletion = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final _logger = Logger('StatisticsController');

  @override
  void onInit() {
    super.onInit();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    isLoading.value = true;
    try {
      final visits = await _visitsService.fetchVisits();
      _logger.info('Fetched visits: $visits');

      // Calculate overall statistics
      totalVisits.value = visits.length;
      completedVisits.value =
          visits.where((v) => v.status.toLowerCase() == 'completed').length;
      inProgressVisits.value =
          visits.where((v) => v.status.toLowerCase() == 'in progress').length;
      cancelledVisits.value =
          visits.where((v) => v.status.toLowerCase() == 'cancelled').length;
      pendingVisits.value =
          visits.where((v) => v.status.toLowerCase() == 'pending').length;

      // Calculate status distribution
      statusDistribution.clear();
      for (var visit in visits) {
        final status = visit.status.toLowerCase();
        statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
      }

      // Calculate monthly statistics
      final monthlyData = <String, int>{};
      for (var visit in visits) {
        final month =
            '${visit.visitDate.year}-${visit.visitDate.month.toString().padLeft(2, '0')}';
        monthlyData[month] = (monthlyData[month] ?? 0) + 1;
      }

      // Sort months in descending order
      final sortedMonths = monthlyData.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      monthlyStats.value = Map.fromEntries(
        sortedMonths.map((month) => MapEntry(month, monthlyData[month]!)),
      );

      // Calculate activity completion rates
      activityCompletion.clear();
      for (var visit in visits) {
        for (var activity in visit.activitiesDone) {
          activityCompletion[activity] =
              (activityCompletion[activity] ?? 0) + 1;
        }
      }

      _logger.info('Statistics calculated successfully');
      _logger.info('Total visits: ${totalVisits.value}');
      _logger.info('Completed visits: ${completedVisits.value}');
      _logger.info('Status distribution: ${statusDistribution.value}');
      _logger.info('Monthly stats: ${monthlyStats.value}');
      _logger.info('Activity completion: ${activityCompletion.value}');
    } catch (e) {
      _logger.severe('Error fetching statistics: $e');
      print('Error fetching statistics: $e');
      Get.snackbar(
        'Error',
        'Failed to load statistics',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  double getCompletionRate() {
    if (totalVisits.value == 0) return 0;
    return (completedVisits.value / totalVisits.value) * 100;
  }

  String getMostCommonStatus() {
    if (statusDistribution.isEmpty) return 'N/A';
    final mostCommon =
        statusDistribution.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostCommon.key[0].toUpperCase() + mostCommon.key.substring(1);
  }

  String getMostActiveMonth() {
    if (monthlyStats.isEmpty) return 'N/A';
    final month =
        monthlyStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return '${date.year} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  List<String> getTopActivities() {
    if (activityCompletion.isEmpty) return [];
    final sortedEntries = activityCompletion.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(5).map((e) => e.key).toList();
  }
}

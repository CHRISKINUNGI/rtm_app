import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/visits_service.dart';
import '../../visits/models/visit.dart';

class HomeController extends GetxController {
  final VisitsService _visitsService = Get.find<VisitsService>();
  final RxList<Visit> recentVisits = <Visit>[].obs;
  final RxInt todayVisitsCount = 0.obs;
  final RxInt completedVisitsCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecentVisits();
  }

  Future<void> fetchRecentVisits() async {
    isLoading.value = true;
    try {
      final visits = await _visitsService.fetchVisits();

      // Sort visits by date and take the 5 most recent
      recentVisits.value = visits
        ..sort((a, b) => b.visitDate.compareTo(a.visitDate))
        ..take(5)
        ..toList();

      // Calculate today's visits
      final today = DateTime.now();
      final todayVisits = visits.where((visit) {
        final visitDate = visit.visitDate.toLocal(); // Convert to local time
        return visitDate.year == today.year &&
            visitDate.month == today.month &&
            visitDate.day == today.day;
      }).toList();
      todayVisitsCount.value = todayVisits.length;

      // Calculate completed visits (remove duplicates)
      final completedVisits = visits
          .where((visit) {
            final status = visit.status.toLowerCase();
            return status == 'completed';
          })
          .toSet()
          .toList(); // Remove duplicates
      completedVisitsCount.value = completedVisits.length;

      // Debug information
      print('=== Visit Statistics ===');
      print('Total visits: ${visits.length}');
      print('Today\'s visits: ${todayVisitsCount.value}');
      print('Completed visits: ${completedVisitsCount.value}');
      print('Today\'s visits details:');
      for (var visit in todayVisits) {
        print(
            '- ${visit.visitDate.toLocal()}: ${visit.status} at ${visit.location}');
      }
      print('Completed visits details:');
      for (var visit in completedVisits) {
        print(
            '- ${visit.visitDate.toLocal()}: ${visit.status} at ${visit.location}');
      }
      print('=====================');
    } catch (e) {
      print('Error fetching visits: $e');
      Get.snackbar(
        'Error',
        'Failed to load recent visits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'offline_storage_service.dart';
import 'visits_service.dart';

class SyncService extends GetxService {
  final OfflineStorageService _offlineStorageService = OfflineStorageService();
  final VisitsService _visitsService = VisitsService();
  final RxBool isSyncing = false.obs;

  Future<void> syncOfflineVisits() async {
    isSyncing.value = true;
    try {
      final offlineVisits = await _offlineStorageService.getOfflineVisits();
      for (final visit in offlineVisits) {
        await _visitsService.createVisit(visit);
      }
      await _offlineStorageService.clearOfflineVisits();
    } catch (e) {
      print('Error syncing offline visits: $e');
    } finally {
      isSyncing.value = false;
    }
  }
} 
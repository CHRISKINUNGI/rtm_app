import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:rtm_app/services/offline_storage_service.dart';
import 'package:rtm_app/modules/visits/models/visit.dart';

void main() {
  late OfflineStorageService offlineStorageService;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    Get.put(prefs);
    offlineStorageService = OfflineStorageService();
    await offlineStorageService.init();
  });

  tearDown(() {
    Get.reset();
  });

  test('storeVisit and getStoredVisits work correctly', () async {
    // Create a simple visit
    final visit = Visit(
      id: "1",
      customerId: "1",
      visitDate: DateTime.now(),
      status: 'Pending',
      location: 'Test Location',
      notes: 'Test Notes',
      activitiesDone: [],
      createdAt: DateTime.now(),
    );

    // Store the visit
    await offlineStorageService.storeVisit(visit);

    // Retrieve stored visits
    final storedVisits = await offlineStorageService.getStoredVisits();

    // Verify
    expect(storedVisits.length, 1);
    expect(storedVisits[0].id, "1");
    expect(storedVisits[0].status, 'Pending');
  });

  test('storePendingVisit and getPendingVisits work correctly', () async {
    // Create a simple visit
    final visit = Visit(
      id: "1",
      customerId: "1",
      visitDate: DateTime.now(),
      status: 'Pending',
      location: 'Test Location',
      notes: 'Test Notes',
      activitiesDone: [],
      createdAt: DateTime.now(),
    );

    // Store the pending visit
    await offlineStorageService.storePendingVisit(visit);

    // Retrieve pending visits
    final pendingVisits = await offlineStorageService.getPendingVisits();

    // Verify
    expect(pendingVisits.length, 1);
    expect(pendingVisits[0].id, "1");
    expect(pendingVisits[0].status, 'Pending');
  });

  group('OfflineStorageService', () {
    test('clearPendingVisits works correctly', () async {
      final visit = Visit(
        id: "0",
        customerId: "1",
        visitDate: DateTime.now(),
        status: 'Pending',
        location: '123 Main St',
        notes: 'Test visit',
        activitiesDone: ['1', '2'],
        createdAt: DateTime.now(),
      );

      await offlineStorageService.storePendingVisit(visit);
      await offlineStorageService.clearPendingVisits();
      final pendingVisits = await offlineStorageService.getPendingVisits();

      expect(pendingVisits.length, 0);
    });

    test('getOfflineVisits returns both stored and pending visits', () async {
      final storedVisit = Visit(
        id: "1",
        customerId: "1",
        visitDate: DateTime.now(),
        status: 'Completed',
        location: '123 Main St',
        notes: 'Stored visit',
        activitiesDone: ['1', '2'],
        createdAt: DateTime.now(),
      );

      final pendingVisit = Visit(
        id: "2",
        customerId: "2",
        visitDate: DateTime.now(),
        status: 'Pending',
        location: '456 Oak St',
        notes: 'Pending visit',
        activitiesDone: ['3', '4'],
        createdAt: DateTime.now(),
      );

      await offlineStorageService.storeVisit(storedVisit);
      await offlineStorageService.storePendingVisit(pendingVisit);

      final offlineVisits = await offlineStorageService.getOfflineVisits();
      expect(offlineVisits.length, 2);
      expect(offlineVisits.any((v) => v.id == "1"), true);
      expect(offlineVisits.any((v) => v.id == "2"), true);
    });

    test('mergeVisits correctly merges server and local visits', () async {
      final localVisit = Visit(
        id: "1",
        customerId: "1",
        visitDate: DateTime.now(),
        status: 'Completed',
        location: '123 Main St',
        notes: 'Local visit',
        activitiesDone: ['1', '2'],
        createdAt: DateTime.now(),
      );

      final serverVisit = Visit(
        id: "2",
        customerId: "2",
        visitDate: DateTime.now(),
        status: 'Completed',
        location: '456 Oak St',
        notes: 'Server visit',
        activitiesDone: ['3', '4'],
        createdAt: DateTime.now(),
      );

      await offlineStorageService.storeVisit(localVisit);
      await offlineStorageService.mergeVisits([serverVisit]);

      final mergedVisits = await offlineStorageService.getStoredVisits();
      expect(mergedVisits.length, 2);
      expect(mergedVisits.any((v) => v.id == "1"), true);
      expect(mergedVisits.any((v) => v.id == "2"), true);
    });
  });
}

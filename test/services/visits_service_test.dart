import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:rtm_app/services/visits_service.dart';
import 'package:rtm_app/services/offline_storage_service.dart';
import 'package:rtm_app/modules/visits/models/visit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late VisitsService visitsService;
  late OfflineStorageService offlineStorageService;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    Get.put(prefs);

    offlineStorageService = OfflineStorageService();
    await offlineStorageService.init();
    Get.put(offlineStorageService);

    visitsService = VisitsService();
  });

  tearDown(() {
    Get.reset();
  });

  test('createVisit stores visit locally when offline', () async {
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

    // Set offline mode
    await offlineStorageService.setNetworkStatus(false);

    // Create visit
    final createdVisit = await visitsService.createVisit(visit);

    // Verify
    expect(createdVisit.id, "1");
    expect(createdVisit.status, 'Pending');

    // Check if it was stored in pending visits
    final pendingVisits = await offlineStorageService.getPendingVisits();
    expect(pendingVisits.length, 1);
    expect(pendingVisits[0].id, "1");
  });

  test('fetchVisits returns local visits when offline', () async {
    // Create a local visit
    final localVisit = Visit(
      id: "1",
      customerId: "1",
      visitDate: DateTime.now(),
      status: 'Pending',
      location: 'Test Location',
      notes: 'Test Notes',
      activitiesDone: [],
      createdAt: DateTime.now(),
    );

    // Store locally
    await offlineStorageService.setNetworkStatus(false);
    await offlineStorageService.storeVisit(localVisit);

    // Fetch visits
    final visits = await visitsService.fetchVisits();

    // Verify
    expect(visits.length, 1);
    expect(visits[0].id, "1");
    expect(visits[0].status, 'Pending');
  });
}

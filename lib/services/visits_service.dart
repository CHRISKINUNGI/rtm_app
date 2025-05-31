import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../modules/visits/models/visit.dart';
import 'offline_storage_service.dart';

/// A service that handles visit-related operations and API communication.
///
/// This service provides functionality for:
/// - Fetching visits from the server
/// - Creating new visits
/// - Syncing pending visits
/// - Handling offline/online states
class VisitsService extends GetxService {
  /// Base URL for the Supabase API
  static const String _baseUrl =
      'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1';

  /// API key for Supabase authentication
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c';

  /// Offline storage service instance
  final OfflineStorageService _offlineStorage =
      Get.find<OfflineStorageService>();

  /// Fetches visits from the server or local storage
  ///
  /// If the device is offline, returns locally stored visits.
  /// If online, fetches from server and merges with local data.
  ///
  /// Returns a list of [Visit] objects.
  Future<List<Visit>> fetchVisits() async {
    if (!_offlineStorage.isOnline.value) {
      return _offlineStorage.getStoredVisits();
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/visits'),
        headers: {
          'apikey': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final serverVisits = data.map((json) => Visit.fromJson(json)).toList();

        // Merge with local visits
        await _offlineStorage.mergeVisits(serverVisits);

        return serverVisits;
      } else {
        // If online request fails, return local data
        return _offlineStorage.getStoredVisits();
      }
    } catch (e) {
      // If any error occurs, return local data
      return _offlineStorage.getStoredVisits();
    }
  }

  /// Creates a new visit
  ///
  /// If the device is offline, stores the visit locally as pending.
  /// If online, creates the visit on the server and stores locally.
  ///
  /// Returns the created [Visit] object.
  Future<Visit> createVisit(Visit visit) async {
    if (!_offlineStorage.isOnline.value) {
      await _offlineStorage.storePendingVisit(visit);
      return visit;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/visits'),
        headers: {
          'apikey': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(visit.toJson()),
      );

      if (response.statusCode == 201) {
        final createdVisit = Visit.fromJson(json.decode(response.body));
        await _offlineStorage.storeVisit(createdVisit);
        return createdVisit;
      } else {
        // If online request fails, store locally
        await _offlineStorage.storePendingVisit(visit);
        return visit;
      }
    } catch (e) {
      // If any error occurs, store locally
      await _offlineStorage.storePendingVisit(visit);
      return visit;
    }
  }

  /// Syncs pending visits with the server
  ///
  /// Attempts to sync all pending visits when the device is online.
  /// Clears pending visits after successful sync.
  Future<void> syncPendingVisits() async {
    if (!_offlineStorage.isOnline.value) return;

    final pendingVisits = await _offlineStorage.getPendingVisits();
    for (final visit in pendingVisits) {
      try {
        await createVisit(visit);
      } catch (e) {
        // Continue with next visit if one fails
        continue;
      }
    }
    await _offlineStorage.clearPendingVisits();
  }
}

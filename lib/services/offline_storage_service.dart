import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/visits/models/visit.dart';

/// A service that handles offline storage and synchronization of visits data.
///
/// This service provides functionality for:
/// - Storing visits locally when offline
/// - Managing pending visits that need to be synced
/// - Handling network status changes
/// - Merging local and server data
/// - Tracking sync status
class OfflineStorageService extends GetxService {
  /// Key for storing visits in SharedPreferences
  static const String _visitsKey = 'offline_visits';

  /// Key for storing pending visits in SharedPreferences
  static const String _pendingVisitsKey = 'pending_visits';

  /// Key for storing last sync timestamp in SharedPreferences
  static const String _lastSyncKey = 'last_sync';

  /// Key for storing network status in SharedPreferences
  static const String _networkStatusKey = 'network_status';

  /// SharedPreferences instance for local storage
  final _prefs = Get.find<SharedPreferences>();

  /// Observable boolean indicating if the device is online
  final isOnline = true.obs;

  /// Initializes the service and loads the network status
  Future<void> init() async {
    isOnline.value = _prefs.getBool(_networkStatusKey) ?? true;
  }

  /// Updates the network status and stores it locally
  Future<void> setNetworkStatus(bool online) async {
    isOnline.value = online;
    await _prefs.setBool(_networkStatusKey, online);
  }

  /// Stores a visit locally
  ///
  /// This method is used when the device is offline or when storing
  /// a visit that has been successfully synced with the server.
  Future<void> storeVisit(Visit visit) async {
    final visits = await getStoredVisits();
    visits.add(visit);
    await _prefs.setString(
        _visitsKey, jsonEncode(visits.map((v) => v.toJson()).toList()));
  }

  /// Stores a visit that needs to be synced with the server
  ///
  /// This method is used when creating a visit while offline or
  /// when a server sync fails.
  Future<void> storePendingVisit(Visit visit) async {
    final pendingVisits = await getPendingVisits();
    pendingVisits.add(visit);
    await _prefs.setString(_pendingVisitsKey,
        jsonEncode(pendingVisits.map((v) => v.toJson()).toList()));
  }

  /// Retrieves all stored visits from local storage
  Future<List<Visit>> getStoredVisits() async {
    final visitsJson = _prefs.getString(_visitsKey);
    if (visitsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(visitsJson);
    return decoded.map((json) => Visit.fromJson(json)).toList();
  }

  /// Retrieves all pending visits that need to be synced
  Future<List<Visit>> getPendingVisits() async {
    final pendingJson = _prefs.getString(_pendingVisitsKey);
    if (pendingJson == null) return [];

    final List<dynamic> decoded = jsonDecode(pendingJson);
    return decoded.map((json) => Visit.fromJson(json)).toList();
  }

  /// Clears all pending visits after successful sync
  Future<void> clearPendingVisits() async {
    await _prefs.remove(_pendingVisitsKey);
  }

  /// Updates the last sync timestamp
  Future<void> updateLastSync() async {
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Retrieves the last sync timestamp
  Future<DateTime?> getLastSync() async {
    final lastSyncStr = _prefs.getString(_lastSyncKey);
    if (lastSyncStr == null) return null;
    return DateTime.parse(lastSyncStr);
  }

  /// Checks if a sync is needed based on last sync time and network status
  Future<bool> needsSync() async {
    if (!isOnline.value) return false;

    final lastSync = await getLastSync();
    if (lastSync == null) return true;

    // Sync if last sync was more than 1 hour ago
    return DateTime.now().difference(lastSync).inHours >= 1;
  }

  /// Updates the online status
  void setOnlineStatus(bool online) {
    isOnline.value = online;
  }

  /// Retrieves all offline visits (both stored and pending)
  Future<List<Visit>> getOfflineVisits() async {
    final storedVisits = await getStoredVisits();
    final pendingVisits = await getPendingVisits();
    return [...storedVisits, ...pendingVisits];
  }

  /// Clears all offline visits
  Future<void> clearOfflineVisits() async {
    await _prefs.remove(_visitsKey);
    await _prefs.remove(_pendingVisitsKey);
  }

  /// Merges server visits with local visits
  ///
  /// This method handles the merging of server and local data,
  /// ensuring that local changes are preserved while incorporating
  /// server updates.
  Future<void> mergeVisits(List<Visit> serverVisits) async {
    final localVisits = await getStoredVisits();
    final mergedVisits = <Visit>[];

    // Add all server visits
    mergedVisits.addAll(serverVisits);

    // Add local visits that don't exist on server
    for (final localVisit in localVisits) {
      if (!serverVisits.any((serverVisit) => serverVisit.id == localVisit.id)) {
        mergedVisits.add(localVisit);
      }
    }

    // Store merged visits
    await _prefs.setString(
        _visitsKey, jsonEncode(mergedVisits.map((v) => v.toJson()).toList()));
  }
}

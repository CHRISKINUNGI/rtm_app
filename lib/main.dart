import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_pages.dart';
import 'modules/visits/controllers/visits_controller.dart';
import 'modules/add_visit/controllers/add_visit_controller.dart';
import 'services/sync_service.dart';
import 'services/visits_service.dart';
import 'services/customers_service.dart';
import 'services/supabase_service.dart';
import 'services/activities_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/offline_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Initialize services in correct order
  final offlineStorage = OfflineStorageService();
  await offlineStorage.init();
  Get.put(offlineStorage);

  Get.put(VisitsService());
  Get.put(CustomersService());
  Get.put(SupabaseService());
  Get.put(SyncService());
  Get.put(ActivitiesService());

  // Then register controllers that depend on services
  Get.put(VisitsController());
  Get.put(AddVisitController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RTM Visits Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

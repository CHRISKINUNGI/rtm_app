import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/visits/bindings/visits_binding.dart';
import '../modules/visits/views/visits_view.dart';
import '../modules/add_visit/bindings/add_visit_binding.dart';
import '../modules/add_visit/views/add_visit_view.dart';
import '../modules/statistics/bindings/statistics_binding.dart';
import '../modules/statistics/views/statistics_view.dart';
import '../modules/main_navigation/main_navigation_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.MAIN_NAVIGATION,
      page: () => const MainNavigationView(),
    ),
    GetPage(
      name: Routes.VISITS,
      page: () => const VisitsView(),
      binding: VisitsBinding(),
    ),
    GetPage(
      name: Routes.ADD_VISIT,
      page: () => const AddVisitView(),
      binding: AddVisitBinding(),
    ),
    GetPage(
      name: Routes.STATISTICS,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
  ];
} 
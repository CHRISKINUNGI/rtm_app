import 'package:get/get.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/visits/views/visits_view.dart';
import '../../modules/add_visit/views/add_visit_view.dart';
import '../../modules/statistics/views/statistics_view.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;
  
  final pages = [
    const HomeView(),
    const VisitsView(),
    const AddVisitView(),
    const StatisticsView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
} 
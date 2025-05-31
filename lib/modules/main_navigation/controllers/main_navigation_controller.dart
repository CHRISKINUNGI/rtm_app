import 'package:get/get.dart';
import '../../home/views/home_view.dart';
import '../../visits/views/visits_view.dart';
import '../../add_visit/views/add_visit_view.dart';
import '../../statistics/views/statistics_view.dart';

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
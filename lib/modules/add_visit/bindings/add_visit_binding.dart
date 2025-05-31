import 'package:get/get.dart';
import '../controllers/add_visit_controller.dart';

class AddVisitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddVisitController>(() => AddVisitController());
  }
} 
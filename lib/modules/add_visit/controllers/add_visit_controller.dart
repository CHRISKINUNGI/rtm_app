import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../customers/models/customer.dart';
import '../../visits/models/visit.dart';
import '../../../services/visits_service.dart';
import '../../../services/customers_service.dart';
import '../../../services/activities_service.dart';

class AddVisitController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  final selectedCustomer = Rxn<Customer>();
  final selectedDate = DateTime.now().obs;
  final selectedStatus = 'Pending'.obs;
  final selectedActivities = <String>[].obs;
  final isLoading = false.obs;

  final customers = <Customer>[].obs;
  final activities = <Map<String, dynamic>>[].obs;

  final VisitsService _visitsService = Get.find<VisitsService>();
  final CustomersService _customersService = Get.find<CustomersService>();
  final ActivitiesService _activitiesService = Get.find<ActivitiesService>();

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
    fetchActivities();
  }

  @override
  void onClose() {
    locationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> fetchCustomers() async {
    try {
      final fetchedCustomers = await _customersService.fetchCustomers();
      customers.value = fetchedCustomers;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchActivities() async {
    try {
      final fetchedActivities = await _activitiesService.fetchActivities();
      activities.value = fetchedActivities;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load activities: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addVisit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCustomer.value == null) {
      Get.snackbar(
        'Error',
        'Please select a customer',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final visit = Visit(
        customerId: selectedCustomer.value!.id.toString(),
        visitDate: selectedDate.value,
        status: selectedStatus.value,
        location: locationController.text,
        notes: notesController.text,
        activitiesDone: selectedActivities,
      );

      await _visitsService.createVisit(visit);

      Get.back();
      Get.snackbar(
        'Success',
        'Visit added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add visit: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

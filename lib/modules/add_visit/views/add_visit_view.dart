import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_visit_controller.dart';
import '../../customers/models/customer.dart';

class AddVisitView extends GetView<AddVisitController> {
  const AddVisitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Visit'),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Customer Dropdown
            Obx(() {
              if (controller.customers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return DropdownButtonFormField<Customer>(
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedCustomer.value,
                items: controller.customers.map((Customer customer) {
                  return DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text(customer.name),
                  );
                }).toList(),
                onChanged: (Customer? customer) {
                  controller.selectedCustomer.value = customer;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),

            // Date Picker
            Obx(() => ListTile(
                  title: const Text('Visit Date'),
                  subtitle: Text(
                      controller.selectedDate.value.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      controller.selectedDate.value = date;
                    }
                  },
                )),
            const SizedBox(height: 16),

            // Status Dropdown
            Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedStatus.value,
                  items: ['Pending', 'In Progress', 'Completed', 'Cancelled']
                      .map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? status) {
                    if (status != null) {
                      controller.selectedStatus.value = status;
                    }
                  },
                )),
            const SizedBox(height: 16),

            // Location Input
            TextFormField(
              controller: controller.locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Activities Multi-select
            Obx(() {
              if (controller.activities.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activities', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: controller.activities.map((activity) {
                      final isSelected = controller.selectedActivities
                          .contains(activity['id'].toString());
                      return FilterChip(
                        label: Text(activity['name'] ?? 'Unnamed Activity'),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            controller.selectedActivities
                                .add(activity['id'].toString());
                          } else {
                            controller.selectedActivities
                                .remove(activity['id'].toString());
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Notes Input
            TextFormField(
              controller: controller.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(() => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.addVisit,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Add Visit'),
                )),
          ],
        ),
      ),
    );
  }
}

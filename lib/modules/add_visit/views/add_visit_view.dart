import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_visit_controller.dart'; // Assuming this path is correct
import '../../customers/models/customer.dart'; // Assuming this path is correct

class AddVisitView extends GetView<AddVisitController> {
  const AddVisitView({Key? key}) : super(key: key);

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Reduced bottom padding
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith( // Reduced from titleLarge
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Visit'),
        elevation: 1,
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 70.0), // Reduced padding
          children: [
            // Customer Section
            Card(
              elevation: 1.5, // Slightly reduced elevation
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)), // Slightly smaller radius
              margin: const EdgeInsets.only(bottom: 16), // Reduced margin
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Customer Details'),
                    Obx(() {
                      bool hasCustomers = controller.customers.isNotEmpty;
                      return DropdownButtonFormField<Customer>(
                        decoration: InputDecoration(
                          labelText: 'Select Customer',
                          hintText: !hasCustomers ? 'Loading customers...' : null, // Use hintText for consistency
                          prefixIcon: Icon(Icons.person_search_outlined, color: colorScheme.primary, size: 22), // Slightly smaller icon
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface.withOpacity(0.8),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Reduced content padding
                        ),
                        value: controller.selectedCustomer.value,
                        items: controller.customers.map((Customer customer) {
                          return DropdownMenuItem<Customer>(
                            value: customer,
                            child: Text(customer.name, style: textTheme.bodyMedium), // Potentially smaller text
                          );
                        }).toList(),
                        onChanged: hasCustomers ? (Customer? customer) {
                          controller.selectedCustomer.value = customer;
                        } : null,
                        validator: (value) {
                          if (hasCustomers && value == null) {
                            return 'Please select a customer';
                          }
                          return null;
                        },
                        isExpanded: true,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Visit Details Section (Date & Status)
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Visit Schedule & Status'),
                    Obx(() => TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: controller.selectedDate.value
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                          decoration: InputDecoration(
                            labelText: 'Visit Date',
                            prefixIcon: Icon(Icons.event_available_outlined, color: colorScheme.primary, size: 22),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor: colorScheme.surface.withOpacity(0.8),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: controller.selectedDate.value,
                              firstDate: DateTime(2000),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365 * 5)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: colorScheme.copyWith(
                                      primary: colorScheme.primary,
                                      onPrimary: colorScheme.onPrimary,
                                    ),
                                    dialogBackgroundColor: colorScheme.surface,
                                  ),
                                  child: child!,
                                );
                              }
                            );
                            if (date != null) {
                              controller.selectedDate.value = date;
                            }
                          },
                        )),
                    const SizedBox(height: 12), // Reduced spacing
                    Obx(() => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.flag_circle_outlined, color: colorScheme.primary, size: 22),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            filled: true,
                            fillColor: colorScheme.surface.withOpacity(0.8),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          value: controller.selectedStatus.value,
                          items: [
                            'Pending',
                            'In Progress',
                            'Completed',
                            'Cancelled'
                          ].map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status, style: textTheme.bodyMedium),
                            );
                          }).toList(),
                          onChanged: (String? status) {
                            if (status != null) {
                              controller.selectedStatus.value = status;
                            }
                          },
                          isExpanded: true,
                        )),
                  ],
                ),
              ),
            ),

            // Location Section
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Visit Location'),
                    TextFormField(
                      controller: controller.locationController,
                      decoration: InputDecoration(
                        labelText: 'Enter Location',
                        prefixIcon: Icon(Icons.pin_drop_outlined, color: colorScheme.primary, size: 22),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: colorScheme.surface.withOpacity(0.8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Activities Section
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Activities / Purpose'),
                    Obx(() {
                      if (controller.activities.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0), // Reduced padding
                          child: Text(
                            "Loading activities or none available...",
                            style: textTheme.bodySmall // Made text smaller
                                ?.copyWith(color: Colors.grey[600]), // Lighter grey
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 6.0, // Reduced spacing
                        runSpacing: 4.0, // Reduced run spacing
                        children: controller.activities.map((activity) {
                          final activityId = activity['id']?.toString();
                          if (activityId == null) return const SizedBox.shrink();

                          final isSelected = controller.selectedActivities
                              .contains(activityId);
                          return FilterChip(
                            labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced label padding
                            label: Text(
                              activity['name'] as String? ?? 'Unnamed Activity',
                              style: TextStyle(
                                fontSize: textTheme.bodySmall?.fontSize, // Smaller font for chip
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                controller.selectedActivities.add(activityId);
                              } else {
                                controller.selectedActivities.remove(activityId);
                              }
                            },
                            backgroundColor: isSelected ? colorScheme.primaryContainer.withOpacity(0.6) : colorScheme.secondaryContainer.withOpacity(0.4),
                            selectedColor: colorScheme.primaryContainer,
                            checkmarkColor: colorScheme.onPrimaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0), // Slightly smaller radius
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.outline.withOpacity(0.3),
                                width: 1, // Thinner border
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced chip padding
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Notes Section
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.only(bottom: 20), // Reduced margin
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Additional Notes'),
                    TextFormField(
                      controller: controller.notesController,
                      decoration: InputDecoration(
                        labelText: 'Enter Notes (Optional)',
                        prefixIcon: Icon(Icons.edit_note_outlined, color: colorScheme.primary, size: 22),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        filled: true,
                        fillColor: colorScheme.surface.withOpacity(0.8),
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                      maxLines: 3, // Reduced max lines
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      style: textTheme.bodyMedium, // Ensure consistent text style
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    icon: controller.isLoading.value
                        ? Container(
                            width: 20, // Smaller loader
                            height: 20,
                            padding: const EdgeInsets.all(2.0),
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2.5, // Thinner stroke
                            ),
                          )
                        : Icon(Icons.save_alt_outlined, color: colorScheme.onPrimary, size: 22), // Smaller icon
                    label: Text(
                      controller.isLoading.value ? 'SAVING...' : 'SAVE VISIT', // Shorter text
                      style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, letterSpacing: 0.4), // Reduced letter spacing
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.addVisit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12.0), // Reduced vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Slightly smaller radius
                      ),
                      elevation: 2.5, // Slightly reduced elevation
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

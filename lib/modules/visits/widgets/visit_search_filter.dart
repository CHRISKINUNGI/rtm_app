import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visits_controller.dart'; // Assuming this path is correct

class VisitSearchFilter extends StatelessWidget {
  final VisitsController controller;

  const VisitSearchFilter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search visits...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 8.0),

            // Filter Options
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
                        isExpanded: true, // Allow dropdown to expand
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          // Consider reducing contentPadding if space is extremely tight:
                          // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        items: ['All', 'Pending', 'Completed', 'Cancelled']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    overflow: TextOverflow.ellipsis, // Handle overflow for status text
                                  ),
                                ))
                            .toList(),
                        onChanged: controller.setStatusFilter,
                      )),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedActivity.value,
                        isExpanded: true, // Allow dropdown to expand
                        decoration: const InputDecoration(
                          labelText: 'Activity',
                          border: OutlineInputBorder(),
                          // Consider reducing contentPadding if space is extremely tight:
                          // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'All',
                            child: Text(
                              'All Activities',
                              overflow: TextOverflow.ellipsis, // Handle overflow
                            ),
                          ),
                          ...controller.activities
                              .map((activity) => DropdownMenuItem(
                                    value: activity['id'].toString(),
                                    child: Text(
                                      activity['description'],
                                      overflow: TextOverflow.ellipsis, // Crucial for long descriptions
                                    ),
                                  )),
                        ],
                        onChanged: controller.setActivityFilter,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Date Range Filter
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      // Potentially reduce padding if TextButton itself contributes to overflow
                      // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onPressed: () => controller.selectDateRange(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Obx(() => Text(
                          controller.dateRangeText.value,
                          overflow: TextOverflow.ellipsis, // Already good
                        )),
                  ),
                ),
                IconButton(
                  onPressed: controller.clearFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear filters',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

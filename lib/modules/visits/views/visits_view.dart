import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visits_controller.dart';
import '../widgets/visit_card.dart'; // Assuming this path is correct
import '../widgets/visit_search_filter.dart'; // Assuming this path is correct
import '../../../services/offline_storage_service.dart'; // Assuming this path is correct

class VisitsView extends GetView<VisitsController> {
  const VisitsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final offlineStorage = Get.find<OfflineStorageService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits'),
        actions: [
          // Network status indicator
          Obx(() => Container(
                // Further reduced horizontal padding
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8), 
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(
                      offlineStorage.isOnline.value
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: offlineStorage.isOnline.value
                          ? Colors.green
                          : Colors.red,
                      size: 20, 
                    ),
                    const SizedBox(width: 2), // Reduced spacing
                    Flexible( 
                      child: Text(
                        offlineStorage.isOnline.value ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: offlineStorage.isOnline.value
                              ? Colors.green
                              : Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              )),
          // Sync button and status
          Obx(() {
            final hasPendingSync = controller.hasPendingSync.value;
            final isOnline = offlineStorage.isOnline.value;
            final syncProgress = controller.syncProgress.value;
            final pendingCount = controller.pendingVisits.length;

            Widget statusIndicatorWidget = const SizedBox.shrink();

            if (hasPendingSync) {
              statusIndicatorWidget = Container(
                // Further reduced horizontal padding
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8), 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sync, color: Colors.orange, size: 20),
                    const SizedBox(width: 2), // Reduced spacing
                    const Flexible( 
                      child: Text(
                        'Syncing...',
                        style: TextStyle(color: Colors.orange),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    const SizedBox(width: 2), // Reduced spacing
                    SizedBox(
                      width: 60, 
                      child: LinearProgressIndicator(
                        value: syncProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.orange),
                      ),
                    ),
                  ],
                ),
              );
            } else if (pendingCount > 0) { 
              statusIndicatorWidget = Container(
                // Further reduced horizontal padding
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8), 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pending_actions, color: Colors.orange, size: 20),
                    const SizedBox(width: 2), // Reduced spacing
                    Flexible( 
                      child: Text(
                        '$pendingCount pending',
                        style: const TextStyle(color: Colors.orange),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Flexible(child: statusIndicatorWidget), 
                IconButton(
                  icon: Icon(
                    Icons.sync,
                    color: isOnline ? const Color.fromARGB(255, 108, 183, 204) : const Color.fromARGB(255, 64, 192, 76),
                  ),
                  // Reducing IconButton's default padding can be tricky without custom widgets.
                  // However, ensuring the content around it is minimal helps.
                  constraints: const BoxConstraints(), // Adding this can sometimes help reduce IconButton's footprint
                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Explicitly set padding for IconButton
                  iconSize: 24, // Default is 24, ensure it's not larger
                  onPressed: isOnline
                      ? () async {
                          try {
                            await controller.syncPendingVisits();
                          } catch (e) {
                            debugPrint("Error during sync: $e");
                          }
                        }
                      : null,
                  tooltip:
                      isOnline ? 'Sync visits' : 'Offline - sync unavailable',
                ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.add),
            constraints: const BoxConstraints(), // Adding this can sometimes help reduce IconButton's footprint
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Explicitly set padding for IconButton
            iconSize: 24, // Default is 24
            onPressed: () => Get.toNamed('/add-visit'),
            tooltip: 'Add new visit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchVisits,
        child: Column(
          children: [
            VisitSearchFilter(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.visits.isEmpty) { 
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredVisits.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            controller.visits.isEmpty
                                ? 'No visits found'
                                : 'No visits match your filters',
                            textAlign: TextAlign.center, 
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            
                          ),
                          if (controller.visits.isEmpty) ...[ 
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Get.toNamed('/add-visit'),
                              child: const Text('Add your first visit'),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredVisits.length,
                  itemBuilder: (context, index) {
                    final visit = controller.filteredVisits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: VisitCard(visit: visit),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-visit'),
        tooltip: 'Add new visit', 
        child: const Icon(Icons.add),
      ),
    );
  }
}

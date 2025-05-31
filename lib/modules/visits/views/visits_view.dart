import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visits_controller.dart';
import '../widgets/visit_card.dart';
import '../widgets/visit_search_filter.dart';
import '../../../services/offline_storage_service.dart';

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      offlineStorage.isOnline.value
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: offlineStorage.isOnline.value
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offlineStorage.isOnline.value ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: offlineStorage.isOnline.value
                            ? Colors.green
                            : Colors.red,
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

            return Row(
              children: [
                if (hasPendingSync)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.sync, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text(
                          'Syncing...',
                          style: TextStyle(color: Colors.orange),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            value: syncProgress,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (pendingCount > 0 && !hasPendingSync)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.pending_actions, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '$pendingCount pending',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.sync,
                    color: isOnline ? Colors.white : Colors.grey,
                  ),
                  onPressed: isOnline
                      ? () async {
                          try {
                            await controller.syncPendingVisits();
                          } catch (e) {
                            // Error handling is done in the controller
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
            onPressed: () => Get.toNamed('/add-visit'),
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
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredVisits.isEmpty) {
                  return Center(
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (controller.visits.isEmpty)
                          TextButton(
                            onPressed: () => Get.toNamed('/add-visit'),
                            child: const Text('Add your first visit'),
                          ),
                      ],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

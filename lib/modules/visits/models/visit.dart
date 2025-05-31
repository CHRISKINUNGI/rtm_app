import 'package:get/get.dart';
import '../../../services/customers_service.dart';

class Visit {
  final String? id;
  final String customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String notes;
  final List<String> activitiesDone;
  final DateTime? createdAt;

  Visit({
    this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    required this.notes,
    required this.activitiesDone,
    this.createdAt,
  });

  String get customerName {
    final customer = Get.find<CustomersService>().getCustomerById(customerId);
    return customer?.name ?? 'Unknown Customer';
  }

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id']?.toString(),
      customerId: json['customer_id']?.toString() ?? '',
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'])
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      activitiesDone: List<String>.from(json['activities_done'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone,
    };

    if (id != null) map['id'] = id!;
    if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();

    return map;
  }
}

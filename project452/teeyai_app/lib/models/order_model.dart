import 'package:cloud_firestore/cloud_firestore.dart';


class OrderModel {
  final String id;
  final String tableNo;
  final DateTime timestamp;
  final Map<String, int> items;
  final double totalPrice;
  final String status;

  OrderModel({
    required this.id,
    required this.tableNo,
    required this.timestamp,
    required this.items,
    required this.totalPrice,
    required this.status,
  });

  factory OrderModel.fromDocument(String id, Map<String, dynamic> data) {
  return OrderModel(
    id: id,
    tableNo: data['tableNo'] ?? '',
    timestamp: (data['timestamp'] as Timestamp).toDate(),
    items: Map<String, int>.from(
      (data['items'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
    ),
    totalPrice: (data['totalPrice'] as num).toDouble(),
    status: data['status'] ?? 'Pending',
  );
}

}

import 'package:equatable/equatable.dart';
import 'medicine_entity.dart';

class InvoiceItem extends Equatable {
  final MedicineEntity medicine;
  final int quantity;

  const InvoiceItem({
    required this.medicine,
    required this.quantity,
  });

  double get totalPrice => medicine.sellingPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicine.id,
      'medicineName': medicine.name,
      'price': medicine.sellingPrice,
      'quantity': quantity,
      'subTotal': totalPrice,
    };
  }

  @override
  List<Object?> get props => [medicine, quantity];
}

class InvoiceEntity extends Equatable {
  final String? id;
  final String uId;
  final String customerName; // اسم صاحب الفاتورة
  final List<InvoiceItem> items;
  final DateTime dateTime;
  final double totalAmount;

  const InvoiceEntity({
    this.id,
    required this.uId,
    required this.customerName,
    required this.items,
    required this.dateTime,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uId': uId,
      'customerName': customerName,
      'items': items.map((x) => x.toMap()).toList(),
      'dateTime': dateTime.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }

  factory InvoiceEntity.fromMap(Map<String, dynamic> map, String docId) {
    return InvoiceEntity(
      id: docId,
      uId: map['uId'] ?? '',
      customerName: map['customerName'] ?? 'عميل نقدي',
      items: [], // Will be populated if needed from nested data
      dateTime: DateTime.parse(map['dateTime']),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, uId, customerName, items, dateTime, totalAmount];
}

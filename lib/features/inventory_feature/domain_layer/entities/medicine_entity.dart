import 'package:equatable/equatable.dart';

class MedicineEntity extends Equatable {
  final String? id;
  final String uId;
  final String name;
  final String genericName; // الاسم العلمي (للبدائل)
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final DateTime expiryDate;
  final String? description;
  final String? imageUrl;
  final String? barcode;
  final String? shelfLocation; // مكان الرف (ميزة تنافسية)

  const MedicineEntity({
    this.id,
    required this.uId,
    required this.name,
    required this.genericName,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.expiryDate,
    this.description,
    this.imageUrl,
    this.barcode,
    this.shelfLocation,
  });

  double get profitPerUnit => sellingPrice - purchasePrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uId': uId,
      'name': name,
      'genericName': genericName,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'shelfLocation': shelfLocation,
    };
  }

  factory MedicineEntity.fromMap(Map<String, dynamic> map, String docId) {
    return MedicineEntity(
      id: docId,
      uId: map['uId'] ?? '',
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      category: map['category'] ?? 'General',
      purchasePrice: (map['purchasePrice'] ?? 0.0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      expiryDate: DateTime.parse(map['expiryDate']),
      description: map['description'],
      imageUrl: map['imageUrl'],
      barcode: map['barcode'],
      shelfLocation: map['shelfLocation'],
    );
  }

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isNearExpiry {
    final now = DateTime.now();
    final twoMonthsFromNow = now.add(const Duration(days: 60));
    return expiryDate.isAfter(now) && expiryDate.isBefore(twoMonthsFromNow);
  }

  @override
  List<Object?> get props => [
        id, uId, name, genericName, category, purchasePrice, 
        sellingPrice, quantity, expiryDate, description, 
        imageUrl, barcode, shelfLocation
      ];
}

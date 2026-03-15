import '../../domain_layer/entity/medicine_entity.dart';

class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.id,
    required super.name,
    required super.price,
    required super.expiryDate,
    required super.stockCount,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      expiryDate: json['expiry_date'] ?? '',
      stockCount: json['stock_count']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'expiry_date': expiryDate,
      'stock_count': stockCount,
    };
  }
}

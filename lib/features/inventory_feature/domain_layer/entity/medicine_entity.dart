import 'package:equatable/equatable.dart';

class MedicineEntity extends Equatable {
  final String id;
  final String name;
  final String price;
  final String expiryDate;
  final String stockCount;

  const MedicineEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.expiryDate,
    required this.stockCount,
  });

  @override
  List<Object?> get props => [id, name, price, expiryDate, stockCount];
}

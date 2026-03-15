import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uId;
  final String email;
  final String name;
  final String phone;
  final String? image;

  const UserEntity({
    required this.uId,
    required this.email,
    required this.name,
    required this.phone,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'email': email,
      'name': name,
      'phone': phone,
      'image': image ?? '',
    };
  }

  @override
  List<Object?> get props => [uId, email, name, phone, image];
}

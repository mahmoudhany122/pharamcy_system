
import '../../domain/entities/auth_entity.dart';

class UserModel extends AuthEntity
{
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.token
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"]?.toString() ?? "0", // تحويل لـ String أضمن
      email: json["email"] ?? "No Email",
      name: json["name"] ?? "Unknown",
      phone: json["phone"] ?? "No Phone",
      // 💡 ضيف حقل الـ Token هنا عشان الكاش
      token: json["token"] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'uId': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
    };
  }

}
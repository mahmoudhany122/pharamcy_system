import '../../../../core/network/dio_helper.dart';
import '../models/auth_model.dart';
import 'auth_remote_data-source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // We use the static DioHelper directly or via an instance if preferred. 
  // Given your DioHelper is static, we'll call it directly.

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await DioHelper.postData(
      url: "login", // Replace with your actual endpoint
      data: {
        'email': email,
        'password': password,
      },
    );
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await DioHelper.postData(
      url: "register", // Replace with your actual endpoint
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );
    return UserModel.fromJson(response.data["data"]);
  }
}

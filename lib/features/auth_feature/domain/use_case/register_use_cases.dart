import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String id,
    required String token,
  }) async {
    return await repository.register(
      id: id,
      name: name,
      password: password,
      email: email,
      phone: phone,
      token: token,
    );
  }
}

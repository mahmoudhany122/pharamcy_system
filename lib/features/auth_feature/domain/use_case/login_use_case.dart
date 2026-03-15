import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}

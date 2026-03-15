import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/auth_remote_data-source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email: email, password: password);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String name,
    required String email,
    required String id,
    required String token,
    required String password,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

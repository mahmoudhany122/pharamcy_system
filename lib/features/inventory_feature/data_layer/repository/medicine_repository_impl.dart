import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain_layer/entity/medicine_entity.dart';
import '../../domain_layer/repository/medicine_repository.dart';
import '../data_sources/medicine_remote_data_source.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MedicineEntity>>> getMedicines() async {
    try {
      final remoteMedicines = await remoteDataSource.getMedicines();
      return Right(remoteMedicines);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MedicineEntity>> searchMedicines(String query) {
    // Implementation for search if needed later
    throw UnimplementedError();
  }
}

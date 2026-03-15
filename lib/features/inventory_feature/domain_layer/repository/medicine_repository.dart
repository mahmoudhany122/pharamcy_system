import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entity/medicine_entity.dart';

abstract class MedicineRepository {
  Future<Either<Failure, List<MedicineEntity>>> getMedicines();
  Future<Either<Failure, MedicineEntity>> searchMedicines(String query);
}

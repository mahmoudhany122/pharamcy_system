import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entity/medicine_entity.dart';
import '../repository/medicine_repository.dart';

class GetMedicinesUseCase {
  final MedicineRepository repository;

  GetMedicinesUseCase(this.repository);

  Future<Either<Failure, List<MedicineEntity>>> call() async {
    return await repository.getMedicines();
  }
}

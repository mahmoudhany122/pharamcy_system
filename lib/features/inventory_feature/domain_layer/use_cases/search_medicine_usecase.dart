import 'package:zamalek_fans_app/core/errors/exceptions.dart';
import 'package:zamalek_fans_app/core/errors/failures.dart';
import 'package:zamalek_fans_app/features/inventory_feature/domain_layer/repository/medicine_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../auth_feature/domain/entities/auth_entity.dart';
import '../entity/medicine_entity.dart';

class SearchMedicinesUseCase
{
  final MedicineRepository repository;
  SearchMedicinesUseCase(this.repository);

  Future<Either<Failure, MedicineEntity>> call({
    required String query
})async
  {
    return await repository.searchMedicines(
      query
    );
  }
}
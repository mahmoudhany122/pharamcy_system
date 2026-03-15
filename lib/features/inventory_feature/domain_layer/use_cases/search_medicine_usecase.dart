import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entity/medicine_entity.dart';
import '../repository/medicine_repository.dart';

class SearchMedicineUseCase {
  final MedicineRepository repository;

  SearchMedicineUseCase(this.repository);

  Future<Either<Failure, MedicineEntity>> call(String query) async {
    return await repository.searchMedicines(query);
  }
}

import 'package:equatable/equatable.dart';
import '../../domain_layer/entity/medicine_entity.dart';

abstract class MedicineStates extends Equatable {
  const MedicineStates();

  @override
  List<Object?> get props => [];
}

class MedicineInitialState extends MedicineStates {}

class GetMedicinesLoadingState extends MedicineStates {}

class GetMedicinesSuccessState extends MedicineStates {
  final List<MedicineEntity> medicines;
  const GetMedicinesSuccessState(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class GetMedicinesErrorState extends MedicineStates {
  final String error;
  const GetMedicinesErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

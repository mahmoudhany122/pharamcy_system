import 'package:equatable/equatable.dart';
import '../../domain_layer/entities/medicine_entity.dart';

abstract class MedicineStates extends Equatable {
  const MedicineStates();

  @override
  List<Object?> get props => [];
}

class MedicineInitialState extends MedicineStates {}

class MedicineLoadingState extends MedicineStates {}

class MedicineSuccessState extends MedicineStates {}

class MedicineErrorState extends MedicineStates {
  final String error;
  const MedicineErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class MedicineAddLoadingState extends MedicineStates {}

class MedicineAddSuccessState extends MedicineStates {}

class MedicineAddErrorState extends MedicineStates {
  final String error;
  const MedicineAddErrorState(this.error);
  @override
  List<Object?> get props => [error];
}

class MedicineSearchState extends MedicineStates {}

class MedicineFilterState extends MedicineStates {}

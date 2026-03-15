import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain_layer/use_cases/get_medicines_usecase.dart';
import 'medicine_states.dart';

class MedicineCubit extends Cubit<MedicineStates> {
  final GetMedicinesUseCase getMedicinesUseCase;

  MedicineCubit({required this.getMedicinesUseCase}) : super(MedicineInitialState());

  Future<void> getMedicines() async {
    emit(GetMedicinesLoadingState());
    
    final result = await getMedicinesUseCase.call();
    
    result.fold(
      (failure) => emit(GetMedicinesErrorState(failure.toString())),
      (medicines) => emit(GetMedicinesSuccessState(medicines)),
    );
  }
}

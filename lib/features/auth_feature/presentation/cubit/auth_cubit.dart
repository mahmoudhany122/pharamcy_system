import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/use_case/login_use_case.dart';
import '../../domain/use_case/register_use_cases.dart';
import 'auth_states.dart';

class UserCubit extends Cubit<AuthStates> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  UserCubit({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(InitialState());

  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibilityState());
  }

  void userLogin({required String email, required String password}) async {
    emit(LoadingState());

    final result = await loginUseCase(email: email, password: password);

    result.fold(
      (failure) => emit(ErrorState(failure.message)),
      (user) => emit(SuccessState(user)),
    );
  }

  void userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String id,
    required String token,
  }) async {
    emit(LoadingState());

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
      id: id,
      token: token,
    );

    result.fold(
      (failure) => emit(ErrorState(failure.message)),
      (user) => emit(SuccessState(user)),
    );
  }
}

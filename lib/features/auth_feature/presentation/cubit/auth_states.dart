import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

abstract class AuthStates extends Equatable {
  const AuthStates();

  @override
  List<Object?> get props => [];
}

class InitialState extends AuthStates {}

class LoadingState extends AuthStates {}

class SuccessState extends AuthStates {
  final AuthEntity user;
  const SuccessState(this.user);

  @override
  List<Object?> get props => [user];
}

class ErrorState extends AuthStates {
  final String error;
  const ErrorState(this.error);

  @override
  List<Object?> get props => [error];
}

class ChangePasswordVisibilityState extends AuthStates {}

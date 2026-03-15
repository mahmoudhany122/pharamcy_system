import 'package:equatable/equatable.dart';

abstract class HomeStates extends Equatable {
  const HomeStates();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeStates {}

class HomeChangeBottomNavState extends HomeStates {
  final int index;
  const HomeChangeBottomNavState(this.index);

  @override
  List<Object?> get props => [index];
}

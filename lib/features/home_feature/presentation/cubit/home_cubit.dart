import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../inventory_feature/presentation/screens/medicine_screen.dart';
import '../../../settings_feature/presentation/pages/settings_screen.dart';
import '../pages/alerts_screen.dart';
import '../pages/pos_screen.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  int currentIndex = 0;

  List<Widget> screens = [
    const MedicineScreen(),
    const PosScreen(),
    const AlertsScreen(),
    const SettingsScreen(),
  ];

  List<String> titles = [
    'المخزن',
    'المبيعات (POS)',
    'التنبيهات',
    'الإعدادات',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(HomeChangeBottomNavState(index));
  }
}

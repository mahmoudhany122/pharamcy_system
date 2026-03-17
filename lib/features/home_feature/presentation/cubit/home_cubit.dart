import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../inventory_feature/presentation/pages/invoices_screen.dart';
import '../../../inventory_feature/presentation/pages/pos_screen.dart';
import '../../../inventory_feature/presentation/screens/medicine_screen.dart';
import '../../../settings_feature/presentation/pages/settings_screen.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screens = [
    const MedicineScreen(),
    const POSScreen(),
    const InvoicesScreen(),
    const SettingsScreen(),
  ];

  List<String> titles = [
    'المخزن',
    'المبيعات (POS)',
    'سجل الفواتير',
    'الإعدادات',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(HomeChangeBottomNavState(index));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zamalek_fans_app/core/utiles/app_colors.dart';
import 'package:zamalek_fans_app/features/home_feature/presentation/cubit/home_cubit.dart';
import '../cubit/home_states.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeStates>(
        builder: (context, state) {
          var cubit = context.read<HomeCubit>();
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Column(
                children: [
                  const Text(
                    "نظام الصيدلية",
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  Text(
                    cubit.titles[cubit.currentIndex],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                      onPressed: () {
                        cubit.changeIndex(2); // Go to Alerts
                      },
                    ),
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: cubit.screens[cubit.currentIndex],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                currentIndex: cubit.currentIndex,
                elevation: 0,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2),
                    label: 'المخزن',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.point_of_sale_outlined),
                    activeIcon: Icon(Icons.point_of_sale),
                    label: 'المبيعات',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_active_outlined),
                    activeIcon: Icon(Icons.notifications_active),
                    label: 'التنبيهات',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'الإعدادات',
                  ),
                ],
              ),
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}

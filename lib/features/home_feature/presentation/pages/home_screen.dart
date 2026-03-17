import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utiles/app_colors.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeMessage();
    });
  }

  void _showWelcomeMessage() {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? "دكتور";
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
        content: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.waving_hand, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "أهلاً بك يا $userName في نظامك الذكي! 🚀",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = HomeCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  const Text(
                    "نظام الصيدلية",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    cubit.titles[cubit.currentIndex],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                // زر التنبيهات في الـ AppBar كما طلبت
                IconButton(
                  icon: const Icon(Icons.notifications_active_outlined, color: Colors.orange),
                  onPressed: () {
                     // هنا ممكن تفتح شاشة التنبيهات كـ Dialog أو Navigate
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قائمة التنبيهات (النواقص والتواريخ)')));
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: cubit.screens[cubit.currentIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              onTap: (index) => cubit.changeIndex(index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'المخزن'),
                BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_outlined), activeIcon: Icon(Icons.point_of_sale), label: 'المبيعات'),
                BottomNavigationBarItem(icon: Icon(Icons.history_edu_outlined), activeIcon: Icon(Icons.history_edu), label: 'سجل الفواتير'), // تم التعديل
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'الإعدادات'),
              ],
            ),
          );
        },
      ),
    );
  }
}

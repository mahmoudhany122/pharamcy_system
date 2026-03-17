import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../../auth_feature/presentation/pages/login_screen.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_states.dart';
import 'dashboard_screen.dart'; //// استدعاء شاشة الداش بورد

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = SettingsCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإعدادات - Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Dashboard Button (The Wow Feature)
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined, color: Colors.blue),
                  title: const Text('لوحة الإحصائيات (الأرباح والمبيعات)', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                ),
                const Divider(),
                // 2. Dark Mode Switch
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('الوضع الليلي / Dark Mode'),
                  trailing: Switch(
                    value: cubit.isDark,
                    onChanged: (value) {
                      cubit.changeAppMode();
                    },
                  ),
                ),
                const Divider(),
                
                // 3. Language Selection
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'اللغة / Language',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('العربية'),
                      selected: cubit.currentLang == 'ar',
                      onSelected: (selected) => cubit.changeLanguage(langCode: 'ar'),
                    ),
                    ChoiceChip(
                      label: const Text('English'),
                      selected: cubit.currentLang == 'en',
                      onSelected: (selected) => cubit.changeLanguage(langCode: 'en'),
                    ),
                    ChoiceChip(
                      label: const Text('Français'),
                      selected: cubit.currentLang == 'fr',
                      onSelected: (selected) => cubit.changeLanguage(langCode: 'fr'),
                    ),
                  ],
                ),
                const Divider(),

                const Spacer(),
                
                // 4. Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CacheHelper.removeData(key: 'uId').then((value) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('تسجيل الخروج / Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

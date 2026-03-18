import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../../auth_feature/presentation/pages/login_screen.dart';
import '../../../inventory_feature/presentation/cubit/medicine_cubit.dart';
import '../../../inventory_feature/presentation/cubit/medicine_states.dart';
import '../../../dashboard_feature/presentation/pages/dashboard_screen.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_states.dart';

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
                // 1. Dashboard Button
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

                // 2. Export Inventory Button (The New Feature)
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: Colors.green),
                  title: const Text('تصدير المخزن لملف Excel', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('حفظ نسخة احتياطية لجميع الأدوية'),
                  onTap: () {
                    MedicineCubit.get(context).exportInventoryToCSV();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الملف ومشاركته...')));
                  },
                ),
                const Divider(),

                // 3. Dark Mode Switch
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('الوضع الليلي / Dark Mode'),
                  trailing: Switch(
                    value: cubit.isDark,
                    onChanged: (value) => cubit.changeAppMode(),
                  ),
                ),
                const Divider(),
                
                // 4. Language Selection
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('اللغة / Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('العربية'),
                      selected: cubit.currentLang == 'ar',
                      onSelected: (selected) => cubit.changeLanguage(langCode: 'ar'),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('English'),
                      selected: cubit.currentLang == 'en',
                      onSelected: (selected) => cubit.changeLanguage(langCode: 'en'),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // 5. Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CacheHelper.removeData(key: 'uId').then((value) {
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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

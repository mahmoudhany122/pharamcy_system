import 'package:flutter/material.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../../auth_feature/presentation/pages/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 30),
            const Text(
              "الإعدادات العامة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),
            _buildSettingsItem(
              icon: Icons.language,
              title: "اللغة",
              trailing: "العربية",
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none_rounded,
              title: "الإشعارات",
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: "الوضع الليلي",
              onTap: () {},
            ),
            const SizedBox(height: 30),
            const Text(
              "عن النظام",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 15),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: "حول التطبيق",
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: "سياسة الخصوصية",
              onTap: () {},
            ),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "د. أحمد محمد",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "مدير الصيدلية",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing != null 
          ? Text(trailing, style: const TextStyle(color: AppColors.textSecondary))
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          CacheHelper.removeData(key: 'token').then((value) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
        },
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text(
          "تسجيل الخروج",
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

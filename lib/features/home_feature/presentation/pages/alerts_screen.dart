import 'package:flutter/material.dart';
import '../../../../core/utiles/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "تنبيهات هامة",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "تابع حالة الأدوية والمخزون بشكل دوري",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAlertItem(
                  title: "أدوية قاربت على الانتهاء",
                  subtitle: "هناك 5 أدوية ستنتهي صلاحيتها خلال شهر",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                _buildAlertItem(
                  title: "نقص في المخزون",
                  subtitle: "دواء 'بانادول اكسترا' وصل للحد الأدنى (3 قطع)",
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.error,
                ),
                _buildAlertItem(
                  title: "تحديثات النظام",
                  subtitle: "تم تحديث قائمة الأسعار بنجاح",
                  icon: Icons.system_update_alt_rounded,
                  color: AppColors.primary,
                ),
                _buildEmptyAlertsState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyAlertsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.done_all_rounded, size: 80, color: Colors.green.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              "لا توجد تنبيهات جديدة",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

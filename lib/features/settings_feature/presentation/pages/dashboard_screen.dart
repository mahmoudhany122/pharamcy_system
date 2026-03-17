import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../inventory_feature/presentation/cubit/medicine_cubit.dart';
import '../../../inventory_feature/presentation/cubit/medicine_states.dart';
import '../../../../core/cache/cahche_helper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uId = CacheHelper.getData(key: 'uId') ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليلات الصيدلية الاحترافية'),
        centerTitle: true,
      ),
      body: BlocBuilder<MedicineCubit, MedicineStates>(
        builder: (context, state) {
          var cubit = MedicineCubit.get(context);
          
          // حساب الإحصائيات الحقيقية من المخزن
          double totalPotentialProfit = cubit.medicines.fold(0.0, (sum, m) => sum + (m.profitPerUnit * m.quantity));
          int totalItems = cubit.medicines.fold(0, (sum, m) => sum + m.quantity);
          var lowStockMedicines = cubit.medicines.where((m) => m.quantity < 5).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invoices')
                .where('uId', isEqualTo: uId)
                .snapshots(),
            builder: (context, invoiceSnapshot) {
              double totalSales = 0;
              if (invoiceSnapshot.hasData) {
                totalSales = invoiceSnapshot.data!.docs.fold(0.0, (sum, doc) => sum + (doc['totalAmount'] ?? 0.0));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // كروت ملخصة
                    Row(
                      children: [
                        Expanded(child: _buildMiniStatCard('المبيعات', '\$${totalSales.toStringAsFixed(1)}', Colors.blue)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMiniStatCard('الربح المتوقع', '\$${totalPotentialProfit.toStringAsFixed(1)}', Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // الرسم البياني للأقسام
                    const Text('توزيع المخزن حسب القسم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                      child: PieChart(
                        PieChartData(
                          sections: _buildRealPieSections(cubit),
                          centerSpaceRadius: 40,
                          sectionsSpace: 5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // قسم النواقص
                    const Text('تنبيه النواقص (أقل من 5 قطع)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 10),
                    if (lowStockMedicines.isEmpty)
                      const Card(child: ListTile(title: Text("المخزن مكتمل ولا يوجد نواقص ✅")))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lowStockMedicines.length > 3 ? 3 : lowStockMedicines.length,
                        itemBuilder: (context, index) {
                          final m = lowStockMedicines[index];
                          return Card(
                            color: Colors.red.withOpacity(0.1),
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Text('باقي: ${m.quantity}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 14)),
          FittedBox(child: Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildRealPieSections(MedicineCubit cubit) {
    // منطق حسابي حقيقي لتوزيع الأقسام
    Map<String, int> counts = {};
    for (var m in cubit.medicines) {
      counts[m.category] = (counts[m.category] ?? 0) + 1;
    }

    List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    int colorIndex = 0;

    return counts.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: e.key,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}

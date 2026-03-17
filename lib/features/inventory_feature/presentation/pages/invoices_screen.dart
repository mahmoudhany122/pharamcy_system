import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/cache/cahche_helper.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uId = CacheHelper.getData(key: 'uId') ?? '';

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .where('uId', isEqualTo: uId)
            // تم تعطيل الترتيب مؤقتاً لتجنب طلب الـ Index وحتى يعمل البرنامج فوراً
            // .orderBy('dateTime', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد فواتير سابقة'));
          }

          var invoices = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              var data = invoices[index].data() as Map<String, dynamic>;
              
              // معالجة التاريخ بأمان
              String formattedDate = "تاريخ غير معروف";
              if (data['dateTime'] != null) {
                DateTime date = DateTime.parse(data['dateTime']);
                formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(data['customerName'] ?? 'عميل نقدي', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formattedDate),
                  trailing: Text(
                    '\$${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    _showInvoiceDetails(context, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> data) {
    var items = data['items'] as List<dynamic>;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text('تفاصيل الفاتورة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const Divider(),
              Text('العميل: ${data['customerName']}'),
              Text('التاريخ: ${data['dateTime']}'),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return ListTile(
                      title: Text(item['medicineName'] ?? ''),
                      subtitle: Text('الكمية: ${item['quantity']} | السعر: ${item['price']}'),
                      trailing: Text('\$${(item['subTotal'] ?? 0.0).toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${(data['totalAmount'] ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

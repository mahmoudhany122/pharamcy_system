import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_states.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import '../../domain_layer/entities/invoice_entity.dart';
import '../../../../core/cache/cahche_helper.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<InvoiceItem> _cartItems = [];
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');
  double _totalAmount = 0.0;
  double _discount = 0.0;

  void _calculateTotal() {
    setState(() {
      _discount = double.tryParse(_discountController.text) ?? 0.0;
      double subTotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
      _totalAmount = subTotal - _discount;
      if (_totalAmount < 0) _totalAmount = 0;
    });
  }

  void _addItemToCart(MedicineEntity medicine) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item.medicine.id == medicine.id);
      if (index != -1) {
        if (_cartItems[index].quantity < medicine.quantity) {
          _cartItems[index] = InvoiceItem(medicine: medicine, quantity: _cartItems[index].quantity + 1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكمية المطلوبة تتجاوز المخزون!')));
        }
      } else {
        if (medicine.quantity > 0) {
          _cartItems.add(InvoiceItem(medicine: medicine, quantity: 1));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذا الدواء نفذ من المخزن!')));
        }
      }
      _calculateTotal();
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      int newQty = _cartItems[index].quantity + delta;
      if (newQty > 0 && newQty <= _cartItems[index].medicine.quantity) {
        _cartItems[index] = InvoiceItem(medicine: _cartItems[index].medicine, quantity: newQty);
      } else if (newQty > _cartItems[index].medicine.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد كمية كافية في المخزن')));
      }
      _calculateTotal();
    });
  }

  Future<void> _completeSale() async {
    if (_cartItems.isEmpty) return;

    setState(() {
      // إظهار لودنج بسيط إذا لزم الأمر
    });

    final uId = CacheHelper.getData(key: 'uId');
    final cubit = MedicineCubit.get(context);

    // 1. إنشاء الفاتورة في Firestore
    final invoice = InvoiceEntity(
      uId: uId,
      customerName: _customerNameController.text.isEmpty ? 'عميل نقدي' : _customerNameController.text,
      items: _cartItems,
      dateTime: DateTime.now(),
      totalAmount: _totalAmount,
    );

    try {
      await FirebaseFirestore.instance.collection('invoices').add(invoice.toMap());

      // 2. خصم الكميات من المخزن
      for (var item in _cartItems) {
        await cubit.reduceStock(item.medicine.id!, item.quantity);
      }

      // 3. إظهار خيارات ما بعد البيع
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تمت العملية بنجاح!'),
          content: const Text('تم حفظ الفاتورة وخصم الكمية من المخزن. ماذا تود أن تفعل الآن؟'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.clear();
                  _customerNameController.clear();
                  _discountController.text = '0';
                  _totalAmount = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('فاتورة جديدة'),
            ),
            ElevatedButton(onPressed: () => _generatePdf(share: false), child: const Text('طباعة')),
            ElevatedButton(onPressed: () => _generatePdf(share: true), child: const Text('واتساب')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في إتمام العملية: $e')));
    }
  }

  Future<void> _generatePdf({bool share = false}) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text('Pharmacy Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),
              pw.Text('Customer: ${_customerNameController.text.isEmpty ? 'Cash Customer' : _customerNameController.text}'),
              pw.Text('Date: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Table.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'Total'],
                data: _cartItems.map((item) => [
                  item.medicine.name,
                  item.quantity.toString(),
                  item.medicine.sellingPrice.toString(),
                  item.totalPrice.toStringAsFixed(2),
                ]).toList(),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Discount: \$${_discount.toStringAsFixed(2)}'),
                    pw.Text('Grand Total: \$${_totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    if (share) {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice for ${_customerNameController.text}');
    } else {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicineCubit, MedicineStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('نقطة البيع - POS'),
            actions: [
              IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _showScanner(context)),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'اسم العميل', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                ),
              ),
              Expanded(
                child: _cartItems.isEmpty
                    ? const Center(child: Text('السلة فارغة، امسح باركود لإضافة دواء'))
                    : ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              title: Text(item.medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                children: [
                                  IconButton(onPressed: () => _updateQuantity(index, -1), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                                  Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(onPressed: () => _updateQuantity(index, 1), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                                  const Spacer(),
                                  Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => setState(() {
                                  _cartItems.removeAt(index);
                                  _calculateTotal();
                                }),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('الخصم:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _calculateTotal(),
                            decoration: const InputDecoration(hintText: '0.0', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                          ),
                        ),
                        const Spacer(),
                        const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Text('\$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cartItems.isEmpty ? null : _completeSale,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: const Text('إصدار الفاتورة (حفظ)', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                final cubit = MedicineCubit.get(context);
                try {
                  final medicine = cubit.medicines.firstWhere((m) => m.barcode == code);
                  _addItemToCart(medicine);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الدواء غير موجود بالمخزن!')));
                }
              }
            }
          },
        ),
      ),
    );
  }
}

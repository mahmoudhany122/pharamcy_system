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
import 'package:confetti/confetti.dart'; // إضافة تأثير الاحتفال
import '../../../../core/cache/cahche_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import '../../domain_layer/entities/invoice_entity.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_states.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final List<InvoiceItem> _cartItems = [];
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');
  late ConfettiController _confettiController;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    setState(() {
      double discount = double.tryParse(_discountController.text) ?? 0.0;
      double subTotal = _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
      _totalAmount = subTotal - discount;
      if (_totalAmount < 0) _totalAmount = 0;
    });
  }

  void _addItemToCart(MedicineEntity medicine) {
    if (medicine.quantity <= 0) {
      _showSubstitutesDialog(medicine);
      return;
    }
    setState(() {
      int index = _cartItems.indexWhere((item) => item.medicine.id == medicine.id);
      if (index != -1) {
        if (_cartItems[index].quantity < medicine.quantity) {
          _cartItems[index] = InvoiceItem(medicine: medicine, quantity: _cartItems[index].quantity + 1);
        }
      } else {
        _cartItems.add(InvoiceItem(medicine: medicine, quantity: 1));
      }
      _calculateTotal();
    });
  }

  void _showSubstitutesDialog(MedicineEntity medicine) {
    final substitutes = MedicineCubit.get(context).getSubstitutes(medicine.genericName, medicine.id!);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("substitutes_available".tr(context)),
        content: SizedBox(
          width: double.maxFinite,
          child: substitutes.isEmpty 
            ? const Text("لا توجد بدائل حالياً")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: substitutes.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(substitutes[index].name),
                  subtitle: Text("باقي: ${substitutes[index].quantity} | الرف: ${substitutes[index].shelfLocation}"),
                  trailing: Text("${substitutes[index].sellingPrice}"),
                  onTap: () {
                    _addItemToCart(substitutes[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
        ),
      ),
    );
  }

  Future<void> _completeSale() async {
    final uId = CacheHelper.getData(key: 'uId');
    final invoice = InvoiceEntity(
      uId: uId,
      customerName: _customerNameController.text.isEmpty ? 'Cash' : _customerNameController.text,
      items: _cartItems,
      dateTime: DateTime.now(),
      totalAmount: _totalAmount,
    );

    try {
      await FirebaseFirestore.instance.collection('invoices').add(invoice.toMap());
      for (var item in _cartItems) {
        await MedicineCubit.get(context).reduceStock(item.medicine.id!, item.quantity);
      }
      
      _confettiController.play(); // تشغيل الانفجار الورقي
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text('تمت العملية بنجاح!', textAlign: TextAlign.center),
          actions: [
            ElevatedButton(onPressed: () => _generatePdf(share: false), child: Text("print_pdf".tr(context))),
            ElevatedButton(onPressed: () => _generatePdf(share: true), child: Text("share_whatsapp".tr(context))),
            TextButton(onPressed: () {
              setState(() => _cartItems.clear());
              Navigator.pop(context);
            }, child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _generatePdf({bool share = false}) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Text("Pharmacy Invoice"))));
    if (share) {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/invoice.pdf");
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)]);
    } else {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("pos".tr(context)),
        actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: () => _showScanner(context))],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _customerNameController,
                  decoration: InputDecoration(labelText: "customer_name".tr(context), border: const OutlineInputBorder()),
                ),
              ),
              Expanded(
                child: _cartItems.isEmpty
                    ? Center(child: Text("cart_empty".tr(context)))
                    : ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            child: ListTile(
                              leading: item.medicine.imageUrl != null 
                                ? Image.network(item.medicine.imageUrl!, width: 50, errorBuilder: (_,__,___) => const Icon(Icons.medication))
                                : const Icon(Icons.medication),
                              title: Text(item.medicine.name),
                              subtitle: Row(
                                children: [
                                  IconButton(onPressed: () => _updateQuantity(index, -1), icon: const Icon(Icons.remove)),
                                  Text("${item.quantity}"),
                                  IconButton(onPressed: () => _updateQuantity(index, 1), icon: const Icon(Icons.add)),
                                ],
                              ),
                              trailing: Text("\$${item.totalPrice}"),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("total".tr(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("\$${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(onPressed: _cartItems.isEmpty ? null : _completeSale, child: Text("complete_sale".tr(context))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive),
        ],
      ),
    );
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      int newQty = _cartItems[index].quantity + delta;
      if (newQty > 0 && newQty <= _cartItems[index].medicine.quantity) {
        _cartItems[index] = InvoiceItem(medicine: _cartItems[index].medicine, quantity: newQty);
      }
      _calculateTotal();
    });
  }

  void _showScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: size.height * 0.7,
        child: MobileScanner(onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) {
            try {
              final medicine = MedicineCubit.get(context).medicines.firstWhere((m) => m.barcode == code);
              _addItemToCart(medicine);
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("غير موجود!")));
            }
          }
        }),
      ),
    );
  }
}

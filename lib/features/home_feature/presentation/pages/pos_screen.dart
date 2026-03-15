import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/utiles/app_colors.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String? lastScannedCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCartHeader(),
        Expanded(
          child: lastScannedCode == null 
              ? _buildEmptyCartView() 
              : _buildScannedItemView(),
        ),
        _buildCheckoutSummary(),
      ],
    );
  }

  Widget _buildCartHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "قائمة المشتريات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          ElevatedButton.icon(
            onPressed: () => _showBarcodeScanner(),
            icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
            label: const Text("مسح باركود", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("امسح باركود الدواء", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      setState(() {
                        lastScannedCode = barcodes.first.rawValue;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("تم إضافة دواء بكود: $lastScannedCode"),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء", style: TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "السلة فارغة حالياً",
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            "اضغط على زر المسح لإضافة أدوية",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedItemView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.medication, color: Colors.white)),
          title: const Text("دواء تم مسحه", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Barcode: $lastScannedCode"),
          trailing: const Text("45.00 ج.م", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildCheckoutSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("الإجمالي", style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
              Text(lastScannedCode == null ? "0.00 ج.م" : "45.00 ج.م", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: lastScannedCode == null ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("إصدار فاتورة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

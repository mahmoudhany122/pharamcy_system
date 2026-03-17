import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import '../pages/edit_medicine_screen.dart'; // استدعاء شاشة التعديل

class MedicineItem extends StatelessWidget {
  final MedicineEntity medicine;

  const MedicineItem({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = medicine.quantity < 10;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(medicine.expiryDate);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // عند الضغط على الدواء يفتح شاشة التعديل فوراً
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMedicineScreen(medicine: medicine),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatusIndicator(isLowStock, medicine.isExpired),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPriceAndStock(medicine.quantity, isLowStock, medicine.sellingPrice),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isLowStock, bool isExpired) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: isExpired ? Colors.red : (isLowStock ? Colors.orange : Colors.blue),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        isExpired ? Icons.warning_rounded : Icons.medical_services,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildPriceAndStock(int stock, bool isLowStock, double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$price ج.م',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLowStock ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isLowStock ? Colors.orange : Colors.green,
              width: 1,
            ),
          ),
          child: Text(
            'المخزون: $stock',
            style: TextStyle(
              color: isLowStock ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

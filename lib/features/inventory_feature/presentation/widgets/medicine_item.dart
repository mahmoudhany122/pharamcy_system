import 'package:flutter/material.dart';
import '../../../../core/utiles/app_colors.dart';
import '../../domain_layer/entity/medicine_entity.dart';

class MedicineItem extends StatelessWidget {
  final MedicineEntity medicine;

  const MedicineItem({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    final int stock = int.tryParse(medicine.stockCount) ?? 0;
    final bool isLowStock = stock < 10;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              // Details if needed
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatusIndicator(isLowStock),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              medicine.expiryDate,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPriceAndStock(stock, isLowStock),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isLowStock) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        gradient: isLowStock ? AppColors.errorGradient : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.medical_services, color: Colors.white, size: 30),
    );
  }

  Widget _buildPriceAndStock(int stock, bool isLowStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${medicine.price} ج.م',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLowStock ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isLowStock ? AppColors.error : AppColors.success,
              width: 1,
            ),
          ),
          child: Text(
            'المخزون: $stock',
            style: TextStyle(
              color: isLowStock ? AppColors.error : AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

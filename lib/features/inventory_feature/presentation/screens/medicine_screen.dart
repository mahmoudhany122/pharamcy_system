import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../core/utiles/app_colors.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_states.dart';
import '../widgets/medicine_item.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MedicineCubit>()..getMedicines(),
      child: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: BlocBuilder<MedicineCubit, MedicineStates>(
              builder: (context, state) {
                if (state is GetMedicinesLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetMedicinesSuccessState) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => MedicineItem(
                      medicine: state.medicines[index],
                    ),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemCount: state.medicines.length,
                  );
                } else if (state is GetMedicinesErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.error, style: const TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.read<MedicineCubit>().getMedicines(),
                          child: const Text("إعادة المحاولة"),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textSecondary),
                  hintText: "ابحث عن دواء...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_states.dart';
import '../pages/add_medicine_screen.dart';
import '../widgets/medicine_item.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<MedicineCubit>()..getMedicines(),
      child: Scaffold(
        // إزالة الـ AppBar من هنا لأنها موجودة في الـ HomeScreen
        body: Column(
          children: [
            _buildSearchAndFilter(context),
            Expanded(
              child: BlocBuilder<MedicineCubit, MedicineStates>(
                builder: (context, state) {
                  var cubit = MedicineCubit.get(context);
                  
                  if (state is MedicineLoadingState && cubit.medicines.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (cubit.filteredMedicines.isEmpty) {
                    return const Center(child: Text("لا توجد أدوية في المخزن"));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => MedicineItem(
                      medicine: cubit.filteredMedicines[index],
                    ),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemCount: cubit.filteredMedicines.length,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (value) {
                  MedicineCubit.get(context).searchMedicine(value);
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "ابحث عن دواء...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/dependency_injection/service_locator.dart';
import '../../../../core/localization/app_localizations.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_states.dart';
import '../pages/add_medicine_screen.dart';
import '../widgets/medicine_item.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: sl<MedicineCubit>()..getMedicines(),
      child: Scaffold(
        body: Column(
          children: [
            _buildSearchField(context, size),
            _buildCategoryList(context, size),
            Expanded(
              child: BlocBuilder<MedicineCubit, MedicineStates>(
                builder: (context, state) {
                  var cubit = MedicineCubit.get(context);
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      cubit.getMedicines();
                    },
                    child: _buildContent(context, state, cubit, size),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: ZoomIn(
          child: FloatingActionButton(
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, MedicineStates state, MedicineCubit cubit, Size size) {
    if (state is MedicineLoadingState && cubit.medicines.isEmpty) {
      return _buildShimmerLoading(size);
    }
    
    if (cubit.filteredMedicines.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: size.height * 0.6,
          child: Center(
            child: ElasticIn(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: size.width * 0.25, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "no_medicines".tr(context),
                    style: TextStyle(color: Colors.grey, fontSize: size.width * 0.045),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (context, index) => FadeInUp(
        duration: Duration(milliseconds: 400 + (index * 100)),
        child: MedicineItem(
          medicine: cubit.filteredMedicines[index],
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: cubit.filteredMedicines.length,
    );
  }

  Widget _buildShimmerLoading(Size size) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: size.height * 0.12,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: FadeInDown(
        child: Container(
          height: size.height * 0.06,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: TextField(
            onChanged: (value) => MedicineCubit.get(context).searchMedicine(value),
            decoration: InputDecoration(
              icon: const Icon(Icons.search, color: Colors.blue),
              hintText: "search_hint".tr(context),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, Size size) {
    var cubit = MedicineCubit.get(context);
    return FadeInRight(
      child: SizedBox(
        height: size.height * 0.08,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: cubit.categories.length,
          itemBuilder: (context, index) {
            String category = cubit.categories[index];
            bool isSelected = cubit.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: ActionChip(
                label: Text(category),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: size.width * 0.035,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                elevation: isSelected ? 4 : 0,
                onPressed: () => cubit.filterByCategory(category),
              ),
            );
          },
        ),
      ),
    );
  }
}

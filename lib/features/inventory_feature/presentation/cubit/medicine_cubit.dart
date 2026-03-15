import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import 'medicine_states.dart';

class MedicineCubit extends Cubit<MedicineStates> {
  MedicineCubit() : super(MedicineInitialState());

  static MedicineCubit get(context) => BlocProvider.of(context);

  List<MedicineEntity> medicines = [];
  List<MedicineEntity> filteredMedicines = [];

  void getMedicines() {
    String uId = CacheHelper.getData(key: 'uId') ?? '';
    if (uId.isEmpty) return;

    emit(MedicineLoadingState());
    FirebaseFirestore.instance
        .collection('medicines')
        .where('uId', isEqualTo: uId)
        .snapshots()
        .listen((event) {
      medicines = [];
      for (var element in event.docs) {
        medicines.add(MedicineEntity.fromMap(element.data(), element.id));
      }
      filteredMedicines = medicines;
      emit(MedicineSuccessState());
    });
  }

  void addMedicine(MedicineEntity medicine) {
    emit(MedicineAddLoadingState());
    FirebaseFirestore.instance
        .collection('medicines')
        .add(medicine.toMap())
        .then((value) => emit(MedicineAddSuccessState()))
        .catchError((error) => emit(MedicineAddErrorState(error.toString())));
  }

  // ميزة تعديل بيانات الدواء (سعر، كمية، اسم)
  void updateMedicine(MedicineEntity medicine) {
    FirebaseFirestore.instance
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toMap())
        .then((value) => emit(MedicineSuccessState()));
  }

  // ميزة خصم الكمية بعد البيع
  Future<void> reduceStock(String medicineId, int soldQty) async {
    var doc = FirebaseFirestore.instance.collection('medicines').doc(medicineId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(doc);
      if (snapshot.exists) {
        int newQty = (snapshot.data() as Map<String, dynamic>)['quantity'] - soldQty;
        transaction.update(doc, {'quantity': newQty});
      }
    });
  }

  void searchMedicine(String query) {
    filteredMedicines = medicines
        .where((medicine) => medicine.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(MedicineSearchState());
  }

  final List<String> categories = ['الكل', 'أدوية برد', 'مضادات حيوية', 'أطفال', 'تجميل', 'مسكنات', 'أعصاب', 'أخرى'];

  void filterByCategory(String category) {
    filteredMedicines = category == 'الكل' ? medicines : medicines.where((m) => m.category == category).toList();
    emit(MedicineFilterState());
  }
}

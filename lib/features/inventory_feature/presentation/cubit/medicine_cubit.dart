import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/cache/cahche_helper.dart';
import '../../domain_layer/entities/medicine_entity.dart';
import 'medicine_states.dart';

class MedicineCubit extends Cubit<MedicineStates> {
  MedicineCubit() : super(MedicineInitialState());

  static MedicineCubit get(context) => BlocProvider.of(context);

  List<MedicineEntity> medicines = [];
  List<MedicineEntity> filteredMedicines = [];
  String selectedCategory = 'الكل';
  String lastSearchQuery = '';
  
  StreamSubscription? _medicineSubscription;

  // القائمة الموحدة للأقسام
  final List<String> categories = [
    'الكل', 'أدوية البرد والأنفلونزا', 'المضادات الحيوية', 'المسكنات وخافضات الحرارة',
    'أدوية الجهاز الهضمي', 'أدوية السكري', 'أدوية الضغط والقلب', 'الفيتامينات والمكملات',
    'العناية بالبشرة', 'العناية بالشعر', 'العناية بالطفل', 'أخرى'
  ];

  // تحسين استهلاك Firebase: استخدام Listener واحد وإدارته لمنع تكرار الـ Reads
  void getMedicines() {
    String uId = CacheHelper.getData(key: 'uId') ?? '';
    if (uId.isEmpty) return;

    // إلغاء الاشتراك القديم لمنع تكرار الـ Listeners واستهلاك الميموري
    _medicineSubscription?.cancel();

    emit(MedicineLoadingState());

    _medicineSubscription = FirebaseFirestore.instance
        .collection('medicines')
        .where('uId', isEqualTo: uId)
        .snapshots(includeMetadataChanges: true) // تحسين الكاش
        .listen((event) {
      medicines = event.docs.map((doc) => MedicineEntity.fromMap(doc.data(), doc.id)).toList();
      _applyFilterAndSearch();
      emit(MedicineSuccessState());
    });
  }

  void searchMedicine(String query) {
    lastSearchQuery = query;
    _applyFilterAndSearch();
    emit(MedicineSearchState());
  }

  void filterByCategory(String category) {
    selectedCategory = category;
    _applyFilterAndSearch();
    emit(MedicineFilterState());
  }

  // فلترة محلية (In-Memory) لمنع استهلاك Firebase Reads عند البحث أو التبديل بين الأقسام
  void _applyFilterAndSearch() {
    filteredMedicines = medicines.where((medicine) {
      final matchesCategory = (selectedCategory == 'الكل' || medicine.category == selectedCategory);
      final matchesSearch = medicine.name.toLowerCase().contains(lastSearchQuery.toLowerCase()) ||
                            (medicine.barcode != null && medicine.barcode!.contains(lastSearchQuery)) ||
                            (medicine.genericName.toLowerCase().contains(lastSearchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // تحسين الـ Writes: استخدام الـ Transaction فقط عند الضرورة القصوى
  Future<void> addMedicine(MedicineEntity medicine) async {
    emit(MedicineAddLoadingState());
    try {
      await FirebaseFirestore.instance.collection('medicines').add(medicine.toMap());
      emit(MedicineAddSuccessState());
    } catch (error) {
      emit(MedicineAddErrorState(error.toString()));
    }
  }

  Future<void> updateMedicine(MedicineEntity medicine) async {
    try {
      await FirebaseFirestore.instance.collection('medicines').doc(medicine.id).update(medicine.toMap());
    } catch (e) {
      print(e.toString());
    }
  }

  // خصم الكمية بحماية ضد الأخطاء
  Future<void> reduceStock(String medicineId, int soldQty) async {
    var doc = FirebaseFirestore.instance.collection('medicines').doc(medicineId);
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(doc);
      if (snapshot.exists) {
        int currentQty = (snapshot.data() as Map<String, dynamic>)['quantity'];
        int newQty = currentQty - soldQty;
        transaction.update(doc, {'quantity': newQty >= 0 ? newQty : 0});
      }
    });
  }

  @override
  Future<void> close() {
    _medicineSubscription?.cancel(); // إغلاق الـ Stream لمنع الـ Memory Leak
    return super.close();
  }

  Future<void> exportInventoryToCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(["الاسم", "المادة الفعالة", "القسم", "السعر", "الكمية", "الباركود", "الرف"]);
    for (var m in medicines) {
      rows.add([m.name, m.genericName, m.category, m.sellingPrice, m.quantity, m.barcode ?? "", m.shelfLocation ?? ""]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/inventory_backup_${DateTime.now().millisecondsSinceEpoch}.csv");
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية للمخزن');
  }
}

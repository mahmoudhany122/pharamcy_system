import '../../../../core/network/dio_helper.dart';
import '../models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<List<MedicineModel>> getMedicines();
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  @override
  Future<List<MedicineModel>> getMedicines() async {
    final response = await DioHelper.getData(url: 'medicines'); // Assuming 'medicines' is the endpoint
    
    return (response.data as List)
        .map((e) => MedicineModel.fromJson(e))
        .toList();
  }
}

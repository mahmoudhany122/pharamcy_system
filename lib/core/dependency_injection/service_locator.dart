import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth_feature/presentation/cubit/auth_cubit.dart';
import '../../features/inventory_feature/presentation/cubit/medicine_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! Features - Auth
  sl.registerFactory(() => AuthCubit());

  //! Features - Inventory
  sl.registerFactory(() => MedicineCubit());

  //! External
  sl.registerLazySingleton(() => Dio());
}

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth_feature/data/data_sources/auth_remote_data-source.dart';
import '../../features/auth_feature/data/data_sources/auth_remote_data_source_impl.dart';
import '../../features/auth_feature/data/repository/auth_data _repository_impl.dart';
import '../../features/auth_feature/domain/repository/auth_repository.dart';
import '../../features/auth_feature/domain/use_case/login_use_case.dart';
import '../../features/auth_feature/domain/use_case/register_use_cases.dart';
import '../../features/auth_feature/presentation/cubit/auth_cubit.dart';
import '../../features/inventory_feature/data_layer/data_sources/medicine_remote_data_source.dart';
import '../../features/inventory_feature/data_layer/repository/medicine_repository_impl.dart';
import '../../features/inventory_feature/domain_layer/repository/medicine_repository.dart';
import '../../features/inventory_feature/domain_layer/use_cases/get_medicines_usecase.dart';
import '../../features/inventory_feature/presentation/cubit/medicine_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! Features - Auth
  sl.registerFactory(() => UserCubit(
        loginUseCase: sl(),
        registerUseCase: sl(),
      ));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  //! Features - Inventory
  sl.registerFactory(() => MedicineCubit(getMedicinesUseCase: sl()));

  sl.registerLazySingleton(() => GetMedicinesUseCase(sl()));

  sl.registerLazySingleton<MedicineRepository>(
    () => MedicineRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MedicineRemoteDataSource>(
    () => MedicineRemoteDataSourceImpl(),
  );

  //! External
  sl.registerLazySingleton(() => Dio());
}

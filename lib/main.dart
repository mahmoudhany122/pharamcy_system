import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/cache/cahche_helper.dart';
import 'core/dependency_injection/service_locator.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/dio_helper.dart';
import 'core/network/notification_helper.dart';
import 'core/utiles/app_theme.dart';
import 'features/auth_feature/presentation/cubit/auth_cubit.dart';
import 'features/home_feature/presentation/cubit/home_cubit.dart';
import 'features/inventory_feature/presentation/cubit/medicine_cubit.dart';
import 'features/settings_feature/presentation/cubit/settings_cubit.dart';
import 'features/settings_feature/presentation/cubit/settings_states.dart';
import 'features/splash_feature/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    // تفعيل ميزة العمل بدون إنترنت (Offline Persistence) بأقصى سعة تخزينية
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  await CacheHelper.init();
  DioHelper.init();
  await NotificationHelper.init();
  await setupServiceLocator();

  bool isDark = CacheHelper.getData(key: 'isDark') ?? false;
  String lang = CacheHelper.getData(key: 'lang') ?? 'ar';

  runApp(MyApp(isDark: isDark, lang: lang));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final String lang;
  const MyApp({super.key, required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<HomeCubit>()),
        BlocProvider(create: (context) => sl<AuthCubit>()),
        BlocProvider(create: (context) => sl<MedicineCubit>()..getMedicines()),
        BlocProvider(
          create: (context) => SettingsCubit()
            ..changeAppMode(fromShared: isDark)
            ..changeLanguage(langCode: lang),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsStates>(
        builder: (context, state) {
          var cubit = SettingsCubit.get(context);
          return MaterialApp(
            title: 'Pharmacy System',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            locale: Locale(cubit.currentLang),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: cubit.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

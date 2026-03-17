import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/cahche_helper.dart';
import 'settings_states.dart';

class SettingsCubit extends Cubit<SettingsStates> {
  SettingsCubit() : super(SettingsInitialState());

  static SettingsCubit get(context) => BlocProvider.of(context);

  bool isDark = false;

  void changeAppMode({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
      emit(SettingsChangeThemeState());
    } else {
      isDark = !isDark;
      CacheHelper.saveData(key: 'isDark', value: isDark).then((value) {
        emit(SettingsChangeThemeState());
      });
    }
  }

  String currentLang = 'ar'; // Default to Arabic

  void changeLanguage({String? langCode}) {
    if (langCode != null) {
      currentLang = langCode;
      CacheHelper.saveData(key: 'lang', value: currentLang).then((value) {
        emit(SettingsChangeLanguageState());
      });
    } else {
      // Toggle only between Arabic and English
      if (currentLang == 'ar') {
        currentLang = 'en';
      } else {
        currentLang = 'ar';
      }
      CacheHelper.saveData(key: 'lang', value: currentLang).then((value) {
        emit(SettingsChangeLanguageState());
      });
    }
  }
}

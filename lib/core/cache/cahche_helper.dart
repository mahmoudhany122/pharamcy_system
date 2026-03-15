import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  // 1. لازم يتنادى في الـ main قبل الـ runApp
  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // 2. ميثود شاملة لحفظ أي نوع داتا (String, int, bool, double)
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);

    return await sharedPreferences.setDouble(key, value);
  }

  // 3. ميثود لجلب الداتا
  static dynamic getData({
    required String key,
  }) {
    return sharedPreferences.get(key);
  }

  // 4. ميثود لمسح داتا معينة (زي الـ Logout)
  static Future<bool> removeData({
    required String key,
  }) async {
    return await sharedPreferences.remove(key);
  }

  // 5. ميثود لمسح كل الداتا (Clear All)
  static Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}
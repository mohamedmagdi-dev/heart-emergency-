import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {

  static late SharedPreferences pref;

  static  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

   static Future<bool> saveBool(String key , bool value){
    return pref.setBool(key, value);
  }

  static bool? getBool(String key){
    return pref.getBool(key);
  }

}
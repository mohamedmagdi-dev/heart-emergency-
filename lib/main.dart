import 'package:flutter/material.dart';
import 'config/router.dart';
import 'core/cache/shared_pref_cache.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreference.init();
  bool isFirst = SharedPreference.getBool("isFirst") ?? true;
  runApp(EmergencyApp(isFirst: isFirst));
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key, required this.isFirst});
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'من قلب الطوارئ',
        routerConfig: createAppRouter(isFirst: isFirst),
        theme: ThemeData.light(),
      ),
    );
  }
}

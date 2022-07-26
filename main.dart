import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rigel_fyp_project/screens/client/home.dart';
import 'package:device_preview/device_preview.dart';
import 'package:rigel_fyp_project/screens/freelancer/all_projects_page.dart';
import 'package:rigel_fyp_project/sign_in.dart';
import 'package:rigel_fyp_project/smart_contract/smart_contract_home.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 // runApp(MyApp());
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}


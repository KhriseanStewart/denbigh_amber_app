import 'package:denbigh_app/firebase_options.dart';
import 'package:denbigh_app/screens/dashboard/home.dart';
import 'package:denbigh_app/screens/dashboard/search_screen.dart';
import 'package:denbigh_app/screens/main_layout/main_layout.dart';
import 'package:denbigh_app/screens/notification/notification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:denbigh_app/utils/routes.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Firebase init failed: $e'))),
      ),
    );
    print(e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
home: const MainLayout().
      )
    }
}

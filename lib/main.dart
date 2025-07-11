import 'package:denbigh_app/routes/routes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FarmersApp());
}

class FarmersApp extends StatefulWidget {
  const FarmersApp({super.key});

  @override
  State<FarmersApp> createState() => _FarmersAppState();
}

class _FarmersAppState extends State<FarmersApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Farmers App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        fontFamily: 'Italic',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getroutes(),
    );
  }
}
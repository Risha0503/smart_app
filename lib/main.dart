import 'package:flutter/material.dart ';
import 'package:smart_app/screen/dashboard_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey, //this is the primary color of the app
        primaryColor: const Color.fromARGB(255, 236, 237, 238),
      ),
      home: const DashboardScreen(title:"your manager"),//this is the home screen of the app
    );
  }
}


import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const IoTDashboardApp());
}

class IoTDashboardApp extends StatelessWidget {
  const IoTDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soil Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

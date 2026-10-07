import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MooseTimeApp());
}

class MooseTimeApp extends StatelessWidget {
  const MooseTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MooseTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
import 'package:flutter/material.dart';

class AlertCalculatorScreen extends StatelessWidget {
  const AlertCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alpha / Bravo'),
      ),
      body: const Center(
        child: Text('Alert Calculator Screen'),
      ),
    );
  }
}
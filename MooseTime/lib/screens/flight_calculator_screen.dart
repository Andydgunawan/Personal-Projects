import 'package:flutter/material.dart';

class FlightCalculatorScreen extends StatelessWidget {
  const FlightCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Calculator'),
      ),
      body: const Center(
        child: Text('Flight Calculator Screen'),
      ),
    );
  }
}
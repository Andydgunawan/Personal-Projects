import 'package:flutter/material.dart';

import '../utilities/julian_calendar.dart';
import 'flight_calculator_screen.dart';
import 'alert_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime currentDate;
  late int julianDay;

  @override
  void initState() {
    super.initState();

    currentDate = DateTime.now();
    julianDay = JulianCalendar.dateToJulian(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MooseTime'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Current Julian Day',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      julianDay.toString().padLeft(3, '0'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${currentDate.month}/${currentDate.day}/${currentDate.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const FlightCalculatorScreen(),
                  ),
                );
              },
              child: const Text('Flight Calculator'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AlertCalculatorScreen(),
                  ),
                );
              },
              child: const Text('Alpha / Bravo'),
            ),
          ],
        ),
      ),
    );
  }
}
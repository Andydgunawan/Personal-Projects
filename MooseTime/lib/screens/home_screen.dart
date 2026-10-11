import 'package:flutter/material.dart';

import '../utilities/julian_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMode = 'Airland Augmented';

  DateTime selectedDate = DateTime.now();
  TimeOfDay takeoffTime = const TimeOfDay(hour: 14, minute: 30);

  int zuluConstant = 0;

  bool qualifyingLegLong = false;

  double showTimeAdjustment = 60;
  double stationTimeAdjustment = 45;

  final List<String> calculatorModes = [
    'Airland Basic',
    'Airland Augmented',
    'Airdrop Basic',
    'Airdrop Augmented',
    'Alpha',
    'Bravo',
  ];

  int get julianDay {
    return JulianCalendar.dateToJulian(selectedDate);
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectTakeoffTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: takeoffTime,
    );

    if (pickedTime != null) {
      setState(() {
        takeoffTime = pickedTime;
      });
    }
  }

  String formatTakeoffTime() {
    final hour = takeoffTime.hour.toString().padLeft(2, '0');
    final minute = takeoffTime.minute.toString().padLeft(2, '0');

    return '$hour$minute';
  }

  String formatDate() {
    return '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
  }

  bool get isAugmented {
    return selectedMode == 'Airland Augmented' ||
        selectedMode == 'Airdrop Augmented';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildHeader(),
              buildMainCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEAF3FA),
            Color(0xFFDDEAF5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mission Duty\nCalculator',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2B5A),
              height: 1.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'PLAN SMARTER. FLY FURTHER.',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 0.8,
              color: Color(0xFF6C819B),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildCalculatorDropdown(),
          const Divider(height: 32),

          buildJulianDay(),
          const Divider(height: 32),

          buildTakeoffTime(),
          const Divider(height: 32),

          buildZuluConstant(),
          const Divider(height: 32),

          if (isAugmented) ...[
            buildQualifyingLeg(),
            const Divider(height: 32),
          ],

          buildShowTimeAdjustment(),
          const Divider(height: 32),

          buildStationTimeAdjustment(),

          const SizedBox(height: 24),

          buildCalculateButton(),
        ],
      ),
    );
  }

  Widget buildCalculatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculator Mode',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedMode,
          decoration: inputDecoration(),
          items: calculatorModes.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Text(mode),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMode = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget buildJulianDay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Julian Day',
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: selectDate,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: inputBoxDecoration(),
            child: Row(
              children: [
                Text(
                  julianDay.toString().padLeft(3, '0'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 16),

                const SizedBox(
                  height: 36,
                  child: VerticalDivider(),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    formatDate(),
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),

                const Icon(
                  Icons.calendar_month_outlined,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTakeoffTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Takeoff Time (Zulu)',
              style: sectionTitleStyle,
            ),
            Text(
              'Enter wheels up time',
              style: helperStyle,
            ),
          ],
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: selectTakeoffTime,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: inputBoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTakeoffTime(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildZuluConstant() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Zulu Constant',
              style: sectionTitleStyle,
            ),
            Text(
              'Adjust as required',
              style: helperStyle,
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: inputBoxDecoration(),
                child: Text(
                  '$zuluConstant',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            adjustmentButton(
              icon: Icons.remove,
              onPressed: () {
                setState(() {
                  zuluConstant--;
                });
              },
            ),

            const SizedBox(width: 8),

            adjustmentButton(
              icon: Icons.add,
              onPressed: () {
                setState(() {
                  zuluConstant++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildQualifyingLeg() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Qualifying Legs',
              style: sectionTitleStyle,
            ),
            const SizedBox(width: 8),

            IconButton(
              icon: const Icon(
                Icons.help_outline,
                size: 20,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Qualifying Legs'),
                      content: const Text(
                        'Choose the qualifying-leg rule that applies to the mission.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      '1 x 5 hrs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('OR'),
                    Text(
                      '2 x 3 hrs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Switch(
                value: qualifyingLegLong,
                onChanged: (value) {
                  setState(() {
                    qualifyingLegLong = value;
                  });
                },
              ),

              const Expanded(
                child: Column(
                  children: [
                    Text(
                      '1 x 6 hrs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('OR'),
                    Text(
                      '2 x 4 hrs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildShowTimeAdjustment() {
    return buildSliderSection(
      title: 'Show Time Adjustment',
      helper: 'Delay between alert time and show time',
      value: showTimeAdjustment,
      min: 0,
      max: 75,
      onChanged: (value) {
        setState(() {
          showTimeAdjustment = value;
        });
      },
    );
  }

  Widget buildStationTimeAdjustment() {
    return buildSliderSection(
      title: 'Station Time Adjustment',
      helper: 'Takeoff time minus this adjustment',
      value: stationTimeAdjustment,
      min: 20,
      max: 60,
      onChanged: (value) {
        setState(() {
          stationTimeAdjustment = value;
        });
      },
    );
  }

  Widget buildSliderSection({
    required String title,
    required String helper,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: sectionTitleStyle,
            ),
            Text(
              '${min.toInt()} - ${max.toInt()} min',
              style: helperStyle,
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          helper,
          style: helperStyle,
        ),

        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
              ),
            ),

            Text(
              '${value.round()} min',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCalculateButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Connect calculator classes here next.
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Calculate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  Widget adjustmentButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

const sectionTitleStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
  color: Color(0xFF0A2B5A),
);

const helperStyle = TextStyle(
  fontSize: 12,
  color: Color(0xFF6C819B),
);

InputDecoration inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF8FBFE),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFFD5E2EE),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color(0xFFD5E2EE),
      ),
    ),
  );
}

BoxDecoration inputBoxDecoration() {
  return BoxDecoration(
    color: const Color(0xFFF8FBFE),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: const Color(0xFFD5E2EE),
    ),
  );
}
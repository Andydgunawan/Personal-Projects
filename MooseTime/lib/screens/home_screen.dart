import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utilities/julian_calendar.dart';
import 'results_screen.dart';
import 'announcements_screen.dart';
import '../services/announcement_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.announcementService,
    required this.onCalculated,
  });

  final ValueChanged<ResultsScreen> onCalculated;

  final AnnouncementService announcementService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMode = 'Airland Augmented';

  DateTime selectedDate = DateTime.now();
  final TextEditingController takeoffController = TextEditingController(
    text: '14:30',
  );
  final TextEditingController zuluConstantController = TextEditingController(
    text: '0',
  );
  final TextEditingController earliestAlertController = TextEditingController(
    text: '14:30',
  );

  final TextEditingController showAdjustmentController = TextEditingController(
    text: '60',
  );
  final TextEditingController stationAdjustmentController =
      TextEditingController(text: '45');

  final TextEditingController bravoBurnoutController = TextEditingController(
    text: '48',
  );

  final FocusNode takeoffFocus = FocusNode();
  final FocusNode earliestAlertFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    takeoffFocus.addListener(() {
      if (!takeoffFocus.hasFocus) normalizeTime(takeoffController);
    });
    earliestAlertFocus.addListener(() {
      if (!earliestAlertFocus.hasFocus) normalizeTime(earliestAlertController);
    });
  }

  void normalizeTime(TextEditingController controller) {
    final digits = controller.text.replaceAll(':', '');
    if (digits.isEmpty) return;
    final padded = digits.padLeft(4, '0');
    if (!isValidZuluTime(padded)) return;
    final formatted = '${padded.substring(0, 2)}:${padded.substring(2)}';
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  void dispose() {
    takeoffFocus.dispose();
    earliestAlertFocus.dispose();
    takeoffController.dispose();
    earliestAlertController.dispose();
    zuluConstantController.dispose();
    showAdjustmentController.dispose();
    stationAdjustmentController.dispose();
    bravoBurnoutController.dispose();
    super.dispose();
  }

  bool qualifyingLegLong = false;
  bool isCalculating = false;

  double bravoBurnoutHours = 48;

  double showTimeAdjustment = 60;
  double stationTimeAdjustment = 45;

  final List<String> calculatorModes = [
    'Airland Basic',
    'Airland Augmented',
    'Airdrop Basic',
    'Airdrop Augmented',
    'Alpha Alert',
    'Bravo Alert',
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

  String formatDate() {
    return '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
  }

  bool isValidZuluTime(String value) {
    value = value.replaceAll(':', '');
    if (value.length != 4) {
      return false;
    }

    final hour = int.tryParse(value.substring(0, 2));
    final minute = int.tryParse(value.substring(2, 4));

    if (hour == null || minute == null) {
      return false;
    }

    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  bool isValidZuluConstant(String value) {
    final zulu = int.tryParse(value);

    if (zulu == null) {
      return false;
    }

    return zulu >= -12 && zulu <= 14;
  }

  bool get isAugmented {
    return selectedMode == 'Airland Augmented' ||
        selectedMode == 'Airdrop Augmented';
  }

  bool get isAlertCalculator {
    return selectedMode == 'Alpha Alert' || selectedMode == 'Bravo Alert';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [buildHeader(), buildMainCard()]),
        ),
      ),
    );
  }

  Widget buildAnnouncementsButton() {
    return AnimatedBuilder(
      animation: widget.announcementService,
      builder: (context, _) {
        final unread = widget.announcementService.unreadCount;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.topRight,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 40),
          tooltip: unread == 0
              ? 'Announcements'
              : 'Announcements ($unread unread)',
          onPressed: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (context) =>
                    AnnouncementsScreen(service: widget.announcementService),
              ),
            );
            // The shared notifier updates the badge immediately; rebuild on return too.
            if (mounted) setState(() {});
          },
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            backgroundColor: const Color(0xFF1976D2),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF0A2B5A),
              size: 34,
            ),
          ),
        );
      },
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF3FA), Color(0xFFDDEAF5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Mission Duty\nCalculator',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2B5A),
                    height: 1.0,
                  ),
                ),
              ),
              buildAnnouncementsButton(),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
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

          if (isAlertCalculator) ...[
            buildEarliestAlert(),
            const Divider(height: 32),

            buildZuluConstant(),
            if (selectedMode == 'Bravo Alert') ...[
              const Divider(height: 32),
              buildBravoBurnoutAdjustment(),
            ],
          ] else ...[
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
          ],

          const SizedBox(height: 24),

          buildCalculateButton(),
        ],
      ),
    );
  }

  Widget calculatorModeIcon(String mode) {
    if (mode == 'Airdrop Basic' || mode == 'Airdrop Augmented') {
      return SvgPicture.asset(
        'assets/icons/parachute_cargo.svg',
        width: 22,
        height: 22,
      );
    }
    final icon = switch (mode) {
      'Airland Basic' || 'Airland Augmented' => Icons.flight_land,
      'Alpha Alert' => Icons.notifications_active_outlined,
      'Bravo Alert' => Icons.notifications_active,
      _ => Icons.calculate_outlined,
    };
    return Icon(icon, color: const Color(0xFF0A2B5A), size: 22);
  }

  Widget buildCalculatorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calculator Mode', style: sectionTitleStyle),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          initialValue: selectedMode,
          decoration: inputDecoration(),
          items: calculatorModes.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Row(
                children: [
                  calculatorModeIcon(mode),
                  const SizedBox(width: 10),
                  Text(mode),
                ],
              ),
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
        const Text('Julian Day', style: sectionTitleStyle),
        const SizedBox(height: 8),

        InkWell(
          onTap: selectDate,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

                const SizedBox(height: 36, child: VerticalDivider()),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    formatDate(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 24,
                  height: 24,
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
            Text('Takeoff Time', style: sectionTitleStyle),
            Text('Enter HHMM or HH:MM', style: helperStyle),
          ],
        ),

        const SizedBox(height: 8),

        TextField(
          controller: takeoffController,
          focusNode: takeoffFocus,
          onSubmitted: (_) => normalizeTime(takeoffController),
          onTapOutside: (_) => takeoffFocus.unfocus(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: inputDecoration().copyWith(
            hintText: '14:30',
            suffixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildEarliestAlert() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Earliest Alert', style: sectionTitleStyle),
            Text('Enter HHMM or HH:MM', style: helperStyle),
          ],
        ),

        const SizedBox(height: 8),

        TextField(
          controller: earliestAlertController,
          focusNode: earliestAlertFocus,
          onSubmitted: (_) => normalizeTime(earliestAlertController),
          onTapOutside: (_) => earliestAlertFocus.unfocus(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
            LengthLimitingTextInputFormatter(5),
          ],
          decoration: inputDecoration().copyWith(
            hintText: '14:30',
            suffixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
            Text('Zulu Conversion', style: sectionTitleStyle),
            Text('Enter offset between -12 to +14', style: helperStyle),
          ],
        ),

        const SizedBox(height: 8),
        TextField(
          controller: zuluConstantController,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d{0,2}$')),
          ],
          decoration: inputDecoration().copyWith(
            hintText: '0',
            suffixIcon: const Icon(
              Icons.public,
              color: Color(0xFF0A2B5A),
              size: 24,
            ),
          ),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
            const Text('Qualifying Legs', style: sectionTitleStyle),
            const SizedBox(width: 8),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/info.svg',
                width: 20,
                height: 20,
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

        const SizedBox(height: 8),

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
                    SizedBox(height: 4),
                    Text(
                      'OR',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C819B)),
                    ),
                    SizedBox(height: 4),
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
                    SizedBox(height: 4),
                    Text(
                      'OR',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C819B)),
                    ),
                    SizedBox(height: 4),
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

  Widget buildBravoBurnoutAdjustment() {
    return buildSliderSection(
      title: 'Burnout Time',
      helper: 'Hours from earliest alert to burnout',
      value: bravoBurnoutHours,
      controller: bravoBurnoutController,
      min: 48,
      max: 168,
      unit: 'hrs',
      onChanged: (value) {
        setState(() => bravoBurnoutHours = value);
      },
    );
  }

  Widget buildShowTimeAdjustment() {
    return buildSliderSection(
      title: 'Show Time Adjustment',
      helper: 'Delay between alert time and show time',
      value: showTimeAdjustment,
      controller: showAdjustmentController,
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
      controller: stationAdjustmentController,
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
    required TextEditingController controller,
    String unit = 'min',
  }) {
    void updateText(int minutes) {
      final text = minutes.toString();
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    void finishEditing() {
      final minutes = (int.tryParse(controller.text) ?? value.round()).clamp(
        min.toInt(),
        max.toInt(),
      );
      updateText(minutes);
      onChanged(minutes.toDouble());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: sectionTitleStyle),
            Text('${min.toInt()} - ${max.toInt()} $unit', style: helperStyle),
          ],
        ),

        const SizedBox(height: 4),

        Text(helper, style: helperStyle),

        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: (newValue) {
                  final minutes = newValue.round();
                  updateText(minutes);
                  onChanged(minutes.toDouble());
                },
              ),
            ),

            SizedBox(
              width: 70,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) finishEditing();
                },
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: inputDecoration().copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    suffixText: unit,
                    suffixStyle: helperStyle,
                  ),
                  onChanged: (text) {
                    final minutes = int.tryParse(text);
                    if (minutes != null && minutes >= min && minutes <= max) {
                      onChanged(minutes.toDouble());
                    }
                  },
                  onSubmitted: (_) => finishEditing(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
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
        onPressed: isCalculating
            ? null
            : () async {
                if (isCalculating) return;
                normalizeTime(takeoffController);
                normalizeTime(earliestAlertController);
                final zuluInput = zuluConstantController.text;

                if (isAlertCalculator) {
                  final alertInput = earliestAlertController.text;

                  if (!isValidZuluTime(alertInput)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a valid earliest alert time between 00:00 and 23:59.',
                        ),
                      ),
                    );
                    return;
                  }
                } else {
                  final takeoffInput = takeoffController.text;

                  if (!isValidZuluTime(takeoffInput)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a valid takeoff time between 00:00 and 23:59.',
                        ),
                      ),
                    );
                    return;
                  }
                }

                if (!isValidZuluConstant(zuluInput)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a Zulu Conversion between -12 and +14.',
                      ),
                    ),
                  );
                  return;
                }

                final timeInput =
                    (isAlertCalculator
                            ? earliestAlertController.text
                            : takeoffController.text)
                        .replaceAll(':', '');
                final missionTime = DateTime.utc(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(timeInput.substring(0, 2)),
                  int.parse(timeInput.substring(2, 4)),
                );
                // Snapshot the validated inputs before showing brief feedback.
                final result = ResultsScreen(
                  mode: selectedMode,
                  bravoBurnoutHours: bravoBurnoutHours.round(),
                  zuluTime: missionTime,
                  zuluConstant: int.parse(zuluInput),
                  qualifyingLeg: qualifyingLegLong,
                  showtimeAdjustment: Duration(
                    minutes: showTimeAdjustment.round(),
                  ),
                  stationtimeAdjustment: Duration(
                    minutes: stationTimeAdjustment.round(),
                  ),
                  showBackButton: false,
                );
                setState(() => isCalculating = true);
                try {
                  await Future.delayed(const Duration(milliseconds: 400));
                  if (!mounted) return;
                  widget.onCalculated(result);
                } finally {
                  if (mounted) setState(() => isCalculating = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1976D2),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isCalculating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Calculating...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Calculate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    'assets/icons/forwardarrow.svg',
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget adjustmentButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(onPressed: onPressed, icon: Icon(icon));
  }
}

const sectionTitleStyle = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.bold,
  color: Color(0xFF0A2B5A),
);

const helperStyle = TextStyle(fontSize: 12, color: Color(0xFF6C819B));

InputDecoration inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF8FBFE),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD5E2EE)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFD5E2EE)),
    ),
  );
}

BoxDecoration inputBoxDecoration() {
  return BoxDecoration(
    color: const Color(0xFFF8FBFE),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFD5E2EE)),
  );
}

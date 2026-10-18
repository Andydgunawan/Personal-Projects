import '../services/theme_service.dart';

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../calculators/alert_calculators/alpha.dart';
import '../calculators/alert_calculators/bravo.dart';
import '../calculators/flight_calculators/airland_basic.dart';
import '../calculators/flight_calculators/airland_augmented.dart';
import '../calculators/flight_calculators/airdrop_basic.dart';
import '../calculators/flight_calculators/airdrop_augmented.dart';
import '../calculators/flight_calculators/flight_parent_calculator.dart';
import '../utilities/julian_calendar.dart';
import '../services/result_export_service.dart';
import 'feedback_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.mode,
    required this.zuluTime,
    required this.zuluConstant,
    this.qualifyingLeg = false,
    this.showBackButton = true,
    this.exportService,
    this.bravoBurnoutHours = 48,
    this.showtimeAdjustment = const Duration(minutes: 60),
    this.stationtimeAdjustment = const Duration(minutes: 45),
  });
  final ResultExportService? exportService;
  final String mode;
  final DateTime zuluTime;
  final int zuluConstant;
  final bool qualifyingLeg;
  final bool showBackButton;
  final int bravoBurnoutHours;
  final Duration showtimeAdjustment, stationtimeAdjustment;
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final GlobalKey _exportKey = GlobalKey();
  final Set<String> _hiddenRows = {};
  bool _exporting = false;
  String get mode => widget.mode;
  DateTime get zuluTime => widget.zuluTime;
  int get zuluConstant => widget.zuluConstant;
  bool get qualifyingLeg => widget.qualifyingLeg;
  bool get showBackButton => widget.showBackButton;
  int get bravoBurnoutHours => widget.bravoBurnoutHours;
  Duration get showtimeAdjustment => widget.showtimeAdjustment;
  Duration get stationtimeAdjustment => widget.stationtimeAdjustment;
  ResultExportService get _exportService =>
      widget.exportService ?? ResultExportService();

  String get localLabel => zuluConstant == 0
      ? 'Local (Z)'
      : 'Local (Z ${zuluConstant > 0 ? '-' : '+'} ${zuluConstant.abs()})';
  String duration(Duration d) =>
      '${d.inMinutes.abs() ~/ 60}:${(d.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
  List<_Section> _sections() {
    if (mode == 'Alpha Alert' || mode == 'Bravo Alert') {
      final c = mode == 'Alpha Alert'
          ? Alpha(zuluAlertTime: zuluTime)
          : Bravo(zuluAlertTime: zuluTime, burnoutConstant: bravoBurnoutHours);
      return [
        _Section('Duty Limits', Icons.schedule, [
          _Row(
            '14hr Alert',
            'Alert - 14:00',
            Icons.notifications,
            c.calculateFourteenHrSet(zuluTime),
          ),
          _Row(
            'Last Drink',
            'Alert - 12:00',
            Icons.local_bar,
            c.calculateLastDrink(),
          ),
          _Row(
            'Last Ambien',
            'Alert - 6:00',
            Icons.nightlight_round,
            c.calculateLastAmbien(zuluTime),
          ),
        ]),
        _Section('Alert Times', Icons.event, [
          _Row(
            'Earliest Alert',
            'Entered alert time',
            Icons.notifications,
            zuluTime,
            highlight: true,
          ),
          _Row(
            'Burnout',
            'Alert + ${c.burnoutConstant}:00',
            Icons.timer_off,
            c.calculateBurnoutTime(),
          ),
          _Row(
            'Earliest Reset',
            'Burnout + 12:00',
            Icons.restart_alt,
            c.calculateEarliestReset(),
          ),
        ]),
      ];
    }
    final FlightParentCalculator c = switch (mode) {
      'Airland Basic' => AirlandBasic(zuluTakeoffTime: zuluTime),
      'Airland Augmented' => AirlandAugmented(zuluTakeoffTime: zuluTime),
      'Airdrop Basic' => AirdropBasic(zuluTakeoffTime: zuluTime),
      'Airdrop Augmented' => AirdropAugmented(zuluTakeoffTime: zuluTime),
      _ => throw ArgumentError.value(mode, 'mode'),
    };
    c.setQualifyingLeg(qualifyingLeg);
    c.setShowtimeAdjustment(showtimeAdjustment);
    c.setStationtimeAdjustment(stationtimeAdjustment);
    final alert = c.calculateZuluAlertTime(), show = c.calculateZuluShowTime();
    final extended = c.augmentVariable && qualifyingLeg;
    return [
      _Section('Duty Limits', Icons.schedule, [
        _Row(
          '14hr Alert',
          'Alert - 14:00',
          Icons.notifications,
          c.calculateFourteenHrSet(alert),
        ),
        _Row(
          'Last Drink',
          'Takeoff - 12:00',
          Icons.local_bar,
          c.calculateLastDrink(),
        ),
        _Row(
          'Last Ambien',
          'Alert - 6:00',
          Icons.nightlight_round,
          c.calculateLastAmbien(alert),
        ),
      ]),
      _Section('Mission Times', Icons.flight, [
        _Row(
          'Alert',
          'Takeoff - ${duration(c.alertOffset)}',
          Icons.notifications,
          alert,
        ),
        _Row(
          'Show',
          'Alert + ${duration(showtimeAdjustment)}',
          Icons.desktop_windows,
          show,
        ),
        _Row(
          'Station',
          'Takeoff - ${duration(stationtimeAdjustment)}',
          Icons.location_on,
          c.calculateZuluStationTime(),
        ),
        _Row(
          'Takeoff',
          'Entered takeoff time',
          Icons.flight_takeoff,
          zuluTime,
          highlight: true,
        ),
        _Row(
          'Training Event',
          'Takeoff + 12:00',
          Icons.groups,
          c.calculateZuluTrainingEventTime(),
        ),
        if (c.augmentVariable) ...[
          _Row(
            '3 Stops Left',
            'Show + 14:00',
            Icons.share,
            show.add(Duration(hours: 14)),
          ),
          _Row(
            '2 AC for AR',
            'Show + 14:00',
            Icons.build,
            show.add(Duration(hours: 14)),
          ),
        ],
        _Row(
          'Tactical / AR',
          'Show + ${extended ? 18 : 14}:00',
          Icons.description,
          c.calculateZuluTarTime(),
        ),
        _Row(
          'FDP',
          'Show + ${extended ? 24 : 16}:00',
          Icons.local_gas_station,
          c.calculateZuluFdpTime(),
        ),
        _Row('CDT', 'Show + 18:00', Icons.schedule, c.calculateZuluCdtTime()),
      ]),
      _Section('Other Times', Icons.event, [
        _Row(
          'Latest Alert',
          'Expected alert + 6:00',
          Icons.notifications,
          alert.add(Duration(hours: 6)),
        ),
        _Row(
          'With AC Approval',
          'Expected alert + 8:00',
          Icons.check_circle,
          alert.add(Duration(hours: 8)),
        ),
        _Row(
          'AP Inop FDP',
          'Show + 12:00',
          Icons.description,
          c.calculateZuluApInopFdpTime(),
        ),
      ]),
    ];
  }

  Future<void> _customize() async {
    final rows = _sections().expand((section) => section.rows).toList();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, updateDialog) => AlertDialog(
          backgroundColor: appColor(context, 0xFFF5F8FC),
          title: Text(
            'Customize visible times',
            style: TextStyle(color: appColor(context, 0xFF0A2B5A)),
          ),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final row in rows)
                    CheckboxListTile(
                      title: Text(row.title),
                      value: !_hiddenRows.contains(row.title),
                      activeColor: appColor(context, 0xFF1976D2),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (visible) {
                        setState(() {
                          if (visible == true) {
                            _hiddenRows.remove(row.title);
                          } else {
                            _hiddenRows.add(row.title);
                          }
                        });
                        updateDialog(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(_hiddenRows.clear);
                updateDialog(() {});
              },
              child: Text('Show All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final service = _exportService;
      final Uint8List png = await service.capturePng(_exportKey);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox;
      final origin = box.localToGlobal(Offset.zero) & box.size;
      final date =
          '${zuluTime.year.toString().padLeft(4, '0')}-'
          '${zuluTime.month.toString().padLeft(2, '0')}-'
          '${zuluTime.day.toString().padLeft(2, '0')}';
      final conversion = '${zuluConstant >= 0 ? '+' : ''}$zuluConstant';
      final fileName =
          '${date}_${mode.replaceAll(' ', '-')}_ZuluConversion$conversion.png';
      final action = await showModalBottomSheet<_ExportAction>(
        context: context,
        backgroundColor: appColor(context, 0xFFF5F8FC),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Export result',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColor(context, 0xFF0A2B5A),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.save_alt,
                  color: appColor(context, 0xFF0A2B5A),
                ),
                title: Text('Save as Image'),
                subtitle: Text('Mobile uses the system share/save sheet.'),
                onTap: () => Navigator.pop(context, _ExportAction.save),
              ),
              ListTile(
                leading: Icon(Icons.copy, color: appColor(context, 0xFF0A2B5A)),
                title: Text('Copy Image to Clipboard'),
                subtitle: service.supportsImageClipboard
                    ? null
                    : Text(
                        'Image clipboard unavailable here; saves a PNG instead.',
                      ),
                onTap: () => Navigator.pop(context, _ExportAction.copy),
              ),
              ListTile(
                leading: Icon(
                  Icons.share,
                  color: appColor(context, 0xFF0A2B5A),
                ),
                title: Text('Share'),
                onTap: () => Navigator.pop(context, _ExportAction.share),
              ),
            ],
          ),
        ),
      );
      if (!mounted || action == null) return;
      switch (action) {
        case _ExportAction.save:
          final message = await service.save(png, fileName, origin);
          if (mounted && message != null) _message(message);
        case _ExportAction.copy:
          if (service.supportsImageClipboard) {
            await service.copy(png);
            if (mounted) _message('Result image copied to clipboard.');
          } else {
            final message = await service.save(png, fileName, origin);
            if (mounted && message != null) _message(message);
          }
        case _ExportAction.share:
          await service.share(png, fileName, origin);
      }
    } catch (error, stack) {
      debugPrint('MooseTime Results export failed: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        _message(
          error is ResultExportException
              ? error.toString()
              : error is UnsupportedError
              ? error.message ?? 'This export option is unavailable.'
              : 'Could not export the result: $error. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localDate = zuluTime.subtract(Duration(hours: zuluConstant));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return Scaffold(
      backgroundColor: appColor(context, 0xFFE7F2FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 22, 20, 28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF174529)
                              : const Color(0xFF0A2B5A),
                          appColor(context, 0xFF527D9E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (showBackButton)
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            tooltip: 'Back',
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Results',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                mode,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_exporting)
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          PopupMenuButton<String>(
                            tooltip: 'Results options',
                            icon: Icon(
                              Icons.more_vert,
                              size: 34,
                              color: Colors.white,
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'customize':
                                  _customize();
                                case 'export':
                                  _export();
                                case 'feedback':
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (context) => FeedbackScreen(),
                                    ),
                                  );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'customize',
                                child: Text('Customize visible times'),
                              ),
                              PopupMenuItem(
                                value: 'export',
                                child: Text('Export result'),
                              ),
                              PopupMenuItem(
                                value: 'feedback',
                                child: Text('Feedback & Support'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  RepaintBoundary(
                    key: _exportKey,
                    child: ColoredBox(
                      color: appColor(context, 0xFFE7F2FC),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: appColor(context, 0xFFDDEEFF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  metadata(
                                    Icons.calendar_month,
                                    'Julian Day',
                                    JulianCalendar.dateToJulian(zuluTime)
                                        .toString()
                                        .padLeft(3, '0'),
                                  ),
                                  metadata(
                                    Icons.location_on,
                                    'Zulu Conversion',
                                    '${zuluConstant >= 0 ? '+' : ''}$zuluConstant',
                                  ),
                                  metadata(
                                    Icons.calendar_month,
                                    'Date (Local)',
                                    '${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}',
                                  ),
                                ],
                              ),
                            ),
                            for (final section in _sections())
                              if (section.rows.any(
                                (row) => !_hiddenRows.contains(row.title),
                              )) ...[
                                SizedBox(height: 12),
                                _sectionCard(section),
                              ],
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: appColor(context, 0xFF1976D2),
                                    size: 30,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'All times shown in Zulu (Z) and $localLabel.\nDay badges show days before (-1) or after (+1, +2) the mission date in each column.',
                                      style: TextStyle(
                                        color: appColor(context, 0xFF1976D2),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget metadata(IconData icon, String label, String value) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, color: appColor(context, 0xFF0A2B5A), size: 22),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: appColor(context, 0xFF0A2B5A),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColor(context, 0xFF0A2B5A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _sectionCard(_Section section) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: appColor(context, 0xFFFFFFFF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(section.icon, color: appColor(context, 0xFF0A2B5A), size: 26),
            SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Text(
                section.title,
                style: TextStyle(
                  color: appColor(context, 0xFF0A2B5A),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Zulu (Z)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appColor(context, 0xFF1976D2),
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                localLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appColor(context, 0xFF1976D2),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        for (final row in section.rows.where(
          (row) => !_hiddenRows.contains(row.title),
        ))
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: appColor(context, 0xFFEDF4FB)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: appColor(context, 0xFFEDF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    row.icon,
                    color: appColor(context, 0xFF0A2B5A),
                    size: 20,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.title,
                        style: TextStyle(
                          color: appColor(context, 0xFF0A2B5A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        row.formula,
                        style: TextStyle(
                          color: appColor(context, 0xFF1976D2),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: timeCell(row.time, zuluTime, row.highlight),
                ),
                Expanded(
                  flex: 3,
                  child: timeCell(
                    row.time.subtract(Duration(hours: zuluConstant)),
                    zuluTime.subtract(Duration(hours: zuluConstant)),
                    false,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget timeCell(DateTime time, DateTime reference, bool highlight) {
    final days = DateTime.utc(time.year, time.month, time.day)
        .difference(
          DateTime.utc(reference.year, reference.month, reference.day),
        )
        .inDays;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
      decoration: BoxDecoration(
        color: highlight
            ? appColor(context, 0xFFFFF2A0)
            : appColor(context, 0xFFEAF4FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 3,
        runSpacing: 3,
        children: [
          Text(
            formatted,
            style: TextStyle(
              color: appColor(context, 0xFF0A2B5A),
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (days != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: appColor(context, 0xFF1976D2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${days > 0 ? '+' : ''}$days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _ExportAction { save, copy, share }

class _Section {
  const _Section(this.title, this.icon, this.rows);
  final String title;
  final IconData icon;
  final List<_Row> rows;
}

class _Row {
  const _Row(
    this.title,
    this.formula,
    this.icon,
    this.time, {
    this.highlight = false,
  });
  final String title, formula;
  final IconData icon;
  final DateTime time;
  final bool highlight;
}

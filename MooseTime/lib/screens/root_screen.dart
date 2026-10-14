import 'package:flutter/material.dart';

import '../services/announcement_service.dart';
import 'home_screen.dart';
import 'results_screen.dart';
import 'more_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.announcementService});
  final AnnouncementService announcementService;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  // One immutable result snapshot. A new calculation replaces the old one.
  ResultsScreen? _latestResult;
  int _resultNumber = 0;

  void _showResult(ResultsScreen result) {
    setState(() {
      _latestResult = result;
      _resultNumber++;
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            announcementService: widget.announcementService,
            onCalculated: _showResult,
          ),
          _latestResult == null
              ? const _EmptyResults()
              : KeyedSubtree(
                  key: ValueKey(_resultNumber),
                  child: _latestResult!,
                ),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFFEAF3FA),
        indicatorColor: const Color(0xFFBFD9EF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined, color: Color(0xFF0A2B5A)),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, color: Color(0xFF0A2B5A)),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz, color: Color(0xFF0A2B5A)),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFE7F2FC),
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Color(0xFF0A2B5A)),
            SizedBox(height: 16),
            Text(
              'No calculation yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2B5A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Run a calculation to see your results here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

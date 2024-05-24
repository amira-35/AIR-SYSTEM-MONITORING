import 'package:flutter/material.dart';
import 'package:air_monitoring_app/Views/MapScreen.dart';
import 'package:air_monitoring_app/Views/AlertsScreen.dart';
import 'package:air_monitoring_app/Views/StatisticsScreen.dart';

void main() {
  runApp(AirPollutionApp());
}

class AirPollutionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavBar(),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    MapScreen(),
    Alerts(),
    StatisticsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text('Air curent quality'),
         leading : IconButton(
         icon: const Icon(Icons.air), // Icône de position
    onPressed: () {
      // Action à effectuer lors du clic sur l'icône de position
    },

      ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../account/general/settings.dart';
import '../flood/events.dart';
import '../location/map.dart';

List<String> menuItems = ['History', 'Location', 'Settings'];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = false;
  double availableScreenWidth = 0;
  int selectedIndex = 0;
  bool sortByDateDescending = true;

  @override
  Widget build(BuildContext context) {
    availableScreenWidth = MediaQuery.of(context).size.width - 30;

    return Scaffold(
      body: _buildBody(selectedIndex, availableScreenWidth),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        currentIndex: selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        // unselectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int selectedIndex, double availableScreenWidth) {
    switch (selectedIndex) {
      case 0:
        return const FloodEvents();
      case 1:
        return const FloodMapScreen();
      case 2:
        return const SettingScreen();
      default:
        return const SettingScreen();
    }
  }
}

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTabSelected;
  final VoidCallback onFabPressed;

  const CustomBottomNavBar({
    super.key,
    required this.initialIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex;

  CustomBottomNavBarState() : _currentIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Background with rounded corners
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: backgroundBaseColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
        // Bottom Navigation Bar
        BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: backgroundBaseColor,
              elevation: 0, // Set elevation to 0 to remove shadow
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              selectedItemColor: mainPurpleColor,
              unselectedItemColor: const Color(0xFFC6C6C6), // Inactive color
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt),
                  label: 'Expense',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.savings),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

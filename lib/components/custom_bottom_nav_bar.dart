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
        // Background
        Container(
          height: 80,
          decoration: const BoxDecoration(color: light80),
        ),
        // Bottom Navigation Bar
        BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final icons = [
                  Icons.home_outlined,
                  Icons.receipt,
                  Icons.bar_chart,
                  Icons.settings
                ];
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? purple80
                          : Colors.transparent,
                    ),
                    child: Icon(
                      icons[index],
                      size: 28,
                      color: _currentIndex == index ? Colors.white : dark50,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class TabsWidget extends StatelessWidget {
  final int onselectedIndex;
  final Function(int) onTabSelected;
  final List<String> tabs;

  const TabsWidget({
    super.key,
    required this.onselectedIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF14234B), // Set background color
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) => GestureDetector(
            onTap: () => onTabSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: onselectedIndex == index
                        ? Colors.white // Active tab color (White)
                        : Colors.white, // Inactive tab color (Light Gray)
                  ),
                ),
                if (onselectedIndex == index)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 3,
                    width: 40,
                    color: Colors.white, // Active tab indicator color (White)
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

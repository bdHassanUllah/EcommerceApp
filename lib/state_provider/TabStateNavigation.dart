import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a Notifier class to manage tab state
class TabNotifier extends StateNotifier<int> {
  TabNotifier() : super(0); // Default tab index is 0 (Publications)

  // Method to change the tab index
  void changeTab(int index) {
    state = index;
  }
}

// Riverpod provider for tab navigation
final tabIndexProvider = StateNotifierProvider<TabNotifier, int>((ref) {
  return TabNotifier();
});

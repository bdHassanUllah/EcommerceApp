import 'package:riverpod/riverpod.dart';

// Define a StateNotifier to manage bottom navigation state
class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0); // Default tab index is 0 (Home)

  // Function to update selected index
  void setIndex(int index) {
    state = index;
  }
}

// Create a provider to expose the BottomNavNotifier
final bottomNavProvider = StateNotifierProvider<BottomNavNotifier, int>(
  (ref) => BottomNavNotifier(),
);

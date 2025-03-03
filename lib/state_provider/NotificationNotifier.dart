import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier to manage notifications
class NotificationNotifier extends StateNotifier<String> {
  NotificationNotifier() : super("No new notifications");

  // Function to update notification message
  void updateNotification(String message) {
    state = message;
  }
}

// Create a provider to access the state
final notificationProvider = StateNotifierProvider<NotificationNotifier, String>((ref) {
  return NotificationNotifier();
});

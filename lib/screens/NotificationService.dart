import 'package:e_commerce/state_provider/NotificationNotifier.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart'; // Ensure correct import for Riverpod

class NotificationService {
  static const String oneSignalAppId = "e3d71a27-1802-4708-afa7-54abb4afb034";

  static Future<void> initialize(WidgetRef ref) async {
    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);

    // Request notification permissions
    OneSignal.Notifications.requestPermission(true);

    // Handle incoming notifications
    OneSignal.Notifications.addClickListener((event) {
      print("Notification clicked: ${event.notification.title}");

      // Add notification to the list
      ref.read(notificationProvider.notifier).addNotification(event.notification);
    });

    print("OneSignal initialized successfully");
  }
}

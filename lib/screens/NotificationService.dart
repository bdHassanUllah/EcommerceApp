import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static const String oneSignalAppId = "e3d71a27-1802-4708-afa7-54abb4afb034";

  static Future<void> initialize() async {
    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);

    // Request notification permissions
    OneSignal.Notifications.requestPermission(true);

    // Handle incoming notifications
    OneSignal.Notifications.addClickListener((event) {
      print("Notification clicked: ${event.notification.title}");
    });

    print("OneSignal initialized successfully");
  }
}

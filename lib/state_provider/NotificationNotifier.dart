import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// In NotificationNotifier.dart
final notificationProvider = StateNotifierProvider<NotificationNotifier, List<OSNotification>>((ref) {
  return NotificationNotifier(ref);
});

final hasNotificationProvider = StateProvider<bool>((ref) => false);

class NotificationNotifier extends StateNotifier<List<OSNotification>> {
  final Ref ref;
  
  NotificationNotifier(this.ref) : super([]);

  void addNotification(OSNotification notification) {
    state = [...state, notification];
    ref.read(hasNotificationProvider.notifier).state = true;
  }

  void removeNotification(OSNotification notification) {
    state = state.where((n) => n.notificationId != notification.notificationId).toList();
    if (state.isEmpty) {
      ref.read(hasNotificationProvider.notifier).state = false;
    }
  }
}
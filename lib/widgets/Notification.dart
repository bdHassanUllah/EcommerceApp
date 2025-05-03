import 'package:e_commerce_app/state_provider/NotificationNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to provider state changes
    final notification = ref.watch(notificationProvider);

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        notification as String,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

import '../state_provider/NotificationNotifier.dart';
import '../widgets/BottomNavigationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/HiveModel.dart';
import 'PostDetailScreen.dart';

class NotificationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF2F4568),
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No Notification is available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.red),
                  title: Text(notification.title ?? "No Title",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notification.body ?? "No Content"),
                  onTap: () {
                    // Remove notification from state
                    ref.read(notificationProvider.notifier).removeNotification(notification);

                    // Extract notification data
                    final notificationData = notification.additionalData;
                    if (notificationData != null) {
                      final hiveModel = HiveModel.fromJson(notificationData);

                      // ✅ Navigate to PostDetailScreen the same way as in SearchScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(hiveModels: hiveModel),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
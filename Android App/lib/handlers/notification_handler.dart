import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';

class NotificationHandler {
  // Success Notification
  static void showSuccess(String title, {String? subtitle}) {
    BotToast.showSimpleNotification(
      title: title,
      subTitle: subtitle != null ? Text(subtitle) : null,
      duration: const Duration(seconds: 3),
      closeIcon: const Icon(Icons.check_circle, color: Colors.green),
      backgroundColor: Colors.greenAccent,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Error Notification
  static void showError(String title, {String? subtitle}) {
    BotToast.showSimpleNotification(
      title: title,
      subTitle: subtitle != null ? Text(subtitle) : null,
      duration: const Duration(seconds: 3),
      closeIcon: const Icon(Icons.error, color: Colors.red),
      backgroundColor: Colors.redAccent,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Default Notification
  static void showDefault(String title, {String? subtitle}) {
    BotToast.showSimpleNotification(
      title: title,
      subTitle: subtitle != null ? Text(subtitle) : null,
      duration: const Duration(seconds: 2),
      closeIcon: const Icon(Icons.notifications, color: Colors.blue),
      backgroundColor: Colors.blueAccent,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  static void showErrorNotification(String title, {String? subtitle}) {
    BotToast.showCustomNotification(
      toastBuilder: (cancelFunc) => Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white, // Background color
          border: Border(
            bottom: BorderSide(color: Colors.red, width: 4), // Bottom border
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: cancelFunc, // Close the notification
              icon: const Icon(Icons.close, color: Colors.grey),
              splashRadius: 20, // Reduces the size of the touchable area
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
    );
  }
}

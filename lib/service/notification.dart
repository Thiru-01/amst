import 'package:amst/constant.dart';
import 'package:amst/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificatinDefiner {
  late NotificationDetails platformChannelSpecifics;
  NotificatinDefiner() {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      playSound: true,
      enableVibration: true,
      color: primarySwatch,
      importance: Importance.high,
      priority: Priority.high,
    );
    platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message) async {
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
    );
  }
}

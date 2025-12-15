import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1️⃣ permission
    await _messaging.requestPermission();

    // 2️⃣ get token
    final token = await _messaging.getToken();
    print('=======================================Vendor FCM Token: $token');

    if (token != null) {
      // 3️⃣ save token (Vendor واحد)
      await _firestore.collection('vendor').doc('main').set({
        'fcmToken': token,
      });
    }

    // 4️⃣ local notification init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _local.initialize(settings);

    // 5️⃣ listen foreground notifications
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(message);
    });
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'vendor_channel',
      'Vendor Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Booking',
      message.notification?.body ?? '',
      details,
    );
  }
}

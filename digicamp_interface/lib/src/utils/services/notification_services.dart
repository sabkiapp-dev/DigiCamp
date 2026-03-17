/// Uncomment the file and run the following command
/// flutter pub add firebase_core, firebase_messaging, flutter_local_notifications
/// to work with firebase notification services
///

// import 'dart:async';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// abstract class NotificationServices {
//   /// Creating a Private constructor to prevent instantiating this class
//   NotificationServices._();
//
//   /// Create a [AndroidNotificationChannel] for heads up notifications
//   static AndroidNotificationChannel? _channel;
//
//   /// Initialize the [FlutterLocalNotificationsPlugin] package
//   static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
//
//   /// Initialize the [_firebaseMessaging] instance
//   static FirebaseMessaging? _firebaseMessaging;
//
//   /// the [init] method initializes the Firebase and Firebase messaging services
//   static Future<FirebaseApp> init() async {
//     // initialize firebase
//     final firebase = await Firebase.initializeApp();
//
//     // init [_firebaseMessaging]
//     _firebaseMessaging = FirebaseMessaging.instance;
//
//     // subscribe to all topics
//     await _firebaseMessaging!.subscribeToTopic('all');
//
//     /// init [_channel]
//     _channel = const AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );
//
//     // init local notification plugin
//     _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     await _flutterLocalNotificationsPlugin!
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel!);
//
//     // set messaging options
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     // On background message
//     FirebaseMessaging.onBackgroundMessage(_handleRemoteMessaging);
//
//     // On message opened app
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessaging);
//
//     // On message opened app
//     FirebaseMessaging.onMessage.listen(_handleRemoteMessaging);
//
//     return firebase;
//   }
//
//   /// [_handleRemoteMessaging] method what action will be taken while user gets notification
//   static Future<void> _handleRemoteMessaging(RemoteMessage message) async {
//     await Firebase.initializeApp();
//
//     if (message.data['notify'] == 'true') {
//       if (message.notification != null) {
//         _showNotification(message.notification!);
//       }
//     }
//   }
//
//   /// Method to show notification
//   static Future<void> _showNotification(RemoteNotification notification) async {
//     return await _flutterLocalNotificationsPlugin!.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           _channel!.id,
//           _channel!.name,
//           channelDescription: _channel!.description,
//           icon: 'mipmap/ic_launcher',
//           styleInformation: BigTextStyleInformation(notification.body!),
//         ),
//       ),
//     );
//   }
//
//   // method to get fcm token
//   static Future<String?> getFcmToken() async {
//     // assert initialization of this class
//     assert(
//       _flutterLocalNotificationsPlugin != null &&
//           _channel != null &&
//           _firebaseMessaging != null,
//       'Make sure you have called init() method',
//     );
//     return await _firebaseMessaging!.getToken();
//   }
// }

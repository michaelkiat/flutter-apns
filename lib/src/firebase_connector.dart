import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Map<String, dynamic> getFirebaseMessageMap(RemoteMessage message) {
  return {
    'notification': {
      'title': message?.notification?.title,
      'body': message?.notification?.body,
    },
    'data': message.data,
  };
}

MessageHandler firebaseOnBackgroundMessage;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  firebaseOnBackgroundMessage(getFirebaseMessageMap(message));
}

class FirebasePushConnector extends PushConnector {
  final _firebase = FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    firebaseOnBackgroundMessage = onBackgroundMessage;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(getFirebaseMessageMap(message));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageMap = getFirebaseMessageMap(message);
      if (onLaunch != null) {
        onLaunch(messageMap);
      } else if (onResume != null) {
        onResume(messageMap);
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    _firebase.requestPermission();
  }

  @override
  String get providerType => 'GCM';
}

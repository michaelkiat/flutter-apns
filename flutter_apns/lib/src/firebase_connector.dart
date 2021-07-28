import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_core/firebase_core.dart';

Map<String, dynamic> getFirebaseMessageMap(RemoteMessage message) {
  return {
    'notification': {
      'title': message?.notification?.title,
      'body': message?.notification?.body,
    },
    'data': message?.data,
  };
}

MessageHandler firebaseOnBackgroundMessage;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (firebaseOnBackgroundMessage != null) {
    firebaseOnBackgroundMessage(getFirebaseMessageMap(message));
  }
}

class FirebasePushConnector extends PushConnector {
  var firebase = FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  // bool didInitialize = false;

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) async {
    firebaseOnBackgroundMessage = onBackgroundMessage;
    // if (!didInitialize) {
    //   await Firebase.initializeApp();
    //   didInitialize = true;
    // }

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (onMessage != null) onMessage(getFirebaseMessageMap(message));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageMap = getFirebaseMessageMap(message);
      if (onResume != null) {
        onResume(messageMap);
      }
    });

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final messageMap = getFirebaseMessageMap(initial);
      onLaunch?.call(messageMap);
    }

    token.value = await firebase.getToken();
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() async {
    // if (!didInitialize) {
    //   await Firebase.initializeApp();
    //   didInitialize = true;
    // }

    firebase.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() async {
    // await firebase.setAutoInitEnabled(false);
    // await firebase.deleteToken();

    // token.value = null;
  }
}

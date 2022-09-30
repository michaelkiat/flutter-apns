import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

extension RemoteMessageExt on RemoteMessage {
  Map<String, dynamic> toMap() {
    return {
      'notification': {
        'title': notification?.title,
        'body': notification?.body,
      },
      'data': data,
    };
  }
}

class FirebasePushConnector extends PushConnector {
  FirebaseMessaging _firebase;
  FirebaseMessaging get firebase => _firebase ?? FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  bool didInitialize = false;

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (onMessage != null) onMessage(message?.toMap());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageMap = (message?.toMap());
      if (onResume != null) {
        onResume(messageMap);
      }
    });

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final messageMap = initial?.toMap();
      onLaunch?.call(messageMap);
    }

    token.value = await firebase.getToken();
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

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

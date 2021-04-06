import 'package:flutter_apns/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebasePushConnector extends PushConnector {
  final _firebase = FirebaseMessaging.instance;
  MessageHandler _onBackgroundMessage;

  @override
  final isDisabledByUser = ValueNotifier(false);

  Map<String, dynamic> _getMessageMap(RemoteMessage message) {
    return {
      'notification': {
        'title': message?.notification?.title,
        'body': message?.notification?.body,
      },
      'data': message.data,
    };
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    _onBackgroundMessage(_getMessageMap(message));
  }

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    _onBackgroundMessage = onBackgroundMessage;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(_getMessageMap(message));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final messageMap = _getMessageMap(message);
      if (onLaunch != null) {
        onLaunch(messageMap);
      } else if (onResume != null) {
        onResume(messageMap);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_apns/src/connector.dart';
import 'package:flutter/foundation.dart';
import 'package:huawei_push/push.dart';
import 'package:huawei_push/constants/channel.dart' as Channel;

class HuaweiPushConnector extends PushConnector {
  static const EventChannel TokenEventChannel =
      EventChannel(Channel.TOKEN_CHANNEL);
  static const EventChannel DataMessageEventChannel =
      EventChannel(Channel.DATA_MESSAGE_CHANNEL);

  @override
  final isDisabledByUser = ValueNotifier(false);

  @override
  void configure(
      {onMessage, onLaunch, onResume, onBackgroundMessage, options}) async {
    TokenEventChannel.receiveBroadcastStream().listen((event) {
      token.value = event;
    }, onError: (error) {
      token.value = null;
    });
    DataMessageEventChannel.receiveBroadcastStream().listen((data) {
      onMessage({
        "data": json.decode(data),
      });
    }, onError: (error) {});
    if (onBackgroundMessage != null) {
      Push.setOnBackgroundMsgHandle(onBackgroundMessage);
    }
    Push.getToken();
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() {
    Push.turnOnPush();
  }

  @override
  String get providerType => 'GCM';
}

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
    DataMessageEventChannel.receiveBroadcastStream().listen(
      (data) {
        print(
            '[HuaweiPushConnector] receiveBroadcastStream listen data ==> $data');
        print(
            '[HuaweiPushConnector] receiveBroadcastStream onMessage != null ==> ${onMessage != null}');
        print(
            '[HuaweiPushConnector] receiveBroadcastStream onLaunch != null ==> ${onLaunch != null}');
        print(
            '[HuaweiPushConnector] receiveBroadcastStream onResume != null ==> ${onResume != null}');
        print(
            '[HuaweiPushConnector] receiveBroadcastStream onBackgroundMessage != null ==> ${onBackgroundMessage != null}');

        if (onMessage != null) {
          print(
              '[HuaweiPushConnector] configure json.decode(data) runtimeType ==> ${json.decode(data)?.runtimeType}');
          print(
              '[HuaweiPushConnector] configure json.decode(data) ==> ${json.decode(data)}');

          onMessage({
            "data": json.decode(data),
          });
        }
      },
      onError: (error) {
        print('[HuaweiPushConnector] onError ==> $error');
      },
    );
    print(
        '[HuaweiPushConnector] configure onBackgroundMessage != null ==> ${onBackgroundMessage != null}');
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

  Future<void> unregister() async {
    token.value = null;
  }
}

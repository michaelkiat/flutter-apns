import 'package:flutter_apns_only/flutter_apns_only.dart';
export 'package:flutter_apns_only/flutter_apns_only.dart';

import 'connector.dart';

class ApnsPushConnector extends ApnsPushConnectorOnly implements PushConnector {
  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    ApnsMessageHandler mapHandler(MessageHandler input) {
      if (input == null) {
        return null;
      }

      return (apnsMessage) => input(apnsMessage.payload);
    }

    configureApns(
      onMessage: mapHandler(onMessage),
      onLaunch: mapHandler(onLaunch),
      onResume: mapHandler(onResume),
      onBackgroundMessage: mapHandler(onBackgroundMessage),
    );
  }
}

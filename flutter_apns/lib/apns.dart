import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_apns/src/apns_connector.dart';
import 'package:flutter_apns/src/connector.dart';
import 'package:flutter_apns/src/firebase_connector.dart';
import 'package:flutter_apns/src/huawei_connector.dart';
import 'package:google_api_availability/google_api_availability.dart';

export 'package:flutter_apns/src/connector.dart';
export 'package:flutter_apns/src/apns_connector.dart';
export 'package:flutter_apns/src/firebase_connector.dart';
export 'package:flutter_apns/src/huawei_connector.dart';

/// Creates either APNS or Firebase connector to manage the push notification registration.
Future<PushConnector> createPushConnector() async {
  if (Platform.isAndroid) {
    GooglePlayServicesAvailability availability;
    try {
      availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
    } on PlatformException {
      availability = GooglePlayServicesAvailability.unknown;
    }
    if (availability == GooglePlayServicesAvailability.success) {
      return FirebasePushConnector();
    }
    return HuaweiPushConnector();
  } else {
    return ApnsPushConnector();
  }
}

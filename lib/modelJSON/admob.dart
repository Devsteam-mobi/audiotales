import 'dart:io';

import 'package:audiotales/widgets/audioTales/audioTaleDetails.dart';
import 'package:firebase_admob/firebase_admob.dart';

String getAppId() {
  if (Platform.isIOS) {
    return 'CODE';
  } else if (Platform.isAndroid) {
    return 'CODE';
  }
  return null;
}

//load admob

 const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  testDevices: testDevice != null ? <String>[testDevice] : null,
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  childDirected: true,
  nonPersonalizedAds: true,
);

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'CODE';
  } else if (Platform.isAndroid) {
    return 'CODE';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'CODE';
  } else if (Platform.isAndroid) {
    return 'CODE';
  }
  return null;
}

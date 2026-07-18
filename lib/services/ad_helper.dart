import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if(Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/6300978111';   //test
      return 'ca-app-pub-9085836508167933/5314203719';   //live
    } else if(Platform.isIOS) {
      return 'ca-app-pub-9085836508167933/1727146643';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if(Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/1033173712';   //test
      return 'ca-app-pub-9085836508167933/4194774725';   //live
    } else if(Platform.isIOS) {
      return 'ca-app-pub-9085836508167933/8873185093';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if(Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544/5224354917";   //test
      return "ca-app-pub-9085836508167933/8282158150";   //live
    } else if(Platform.isIOS) {
      return 'ca-app-pub-9085836508167933/7474297346';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/9257395921'; // test
      return 'ca-app-pub-9085836508167933/5842483028'; // live
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9085836508167933/9082321662';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
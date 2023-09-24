import 'package:flutter_svg/flutter_svg.dart';
import 'package:treechan/utils/constants/enums.dart';
import 'package:treechan/utils/string.dart';

System getUserOS(String input) {
  final userInfo = extractUserInfo(input, mode: ExtractMode.info);

  if (userInfo.contains('Microsoft Windows 10')) {
    return System.windows10;
  } else if (userInfo.contains('Google Android')) {
    return System.android;
  } else if (userInfo.contains('Linux')) {
    return System.linux;
  } else if (userInfo.contains('Apple Mac')) {
    return System.macos;
  } else if (userInfo.contains('Microsoft Windows 7')) {
    return System.windows7;
  } else if (userInfo.contains('Microsoft Windows 8')) {
    return System.windows8;
  } else if (userInfo.contains('Microsoft Windows Vista')) {
    return System.windowsVista;
  } else if (userInfo.contains('iOS') || userInfo.contains('Apple GayPhone')) {
    return System.ios;
  } else if (userInfo.contains('Fuchsia')) {
    return System.fuchsia;
  } else if (userInfo.contains('Haiku')) {
    return System.haiku;
  } else {
    return System.unknown;
  }
}

Browser getUserBrowser(String input) {
  final userInfo = extractUserInfo(input, mode: ExtractMode.info);

  if (userInfo.contains('Firefox')) {
    return Browser.firefox;
  } else if (userInfo.contains('Chromium based')) {
    return Browser.chromium;
  } else if (userInfo.contains('Mobile Safari')) {
    return Browser.mobileSafari;
  } else if (userInfo.contains('Safari')) {
    return Browser.safari;
  } else if (userInfo.contains('Opera')) {
    return Browser.opera;
  } else if (userInfo.contains('Яндекс браузер')) {
    return Browser.yandex;
  } else if (userInfo.contains('Palemoon')) {
    return Browser.palemoon;
  } else if (userInfo.contains('Internet Explorer')) {
    return Browser.internetExplorer;
  } else {
    return Browser.unknown;
  }
}

final Map<System, SvgPicture> systemSvgIcons = {
  System.windows10: getSvgAsset('assets/icons/os/windows_10.svg'),
  System.android: getSvgAsset('assets/icons/os/android.svg'),
  System.linux: getSvgAsset('assets/icons/os/linux.svg'),
  System.macos: getSvgAsset('assets/icons/os/macos.svg'),
  System.windows7: getSvgAsset('assets/icons/os/windows_7.svg'),
  System.windowsVista: getSvgAsset('assets/icons/os/windows_vista.svg'),
  System.windows8: getSvgAsset('assets/icons/os/windows_8.svg'),
  System.ios: getSvgAsset('assets/icons/os/ios.svg'),
  System.fuchsia: getSvgAsset('assets/icons/os/fuchsia.svg'),
  System.haiku: getSvgAsset('assets/icons/os/haiku.svg'),
  System.unknown: getSvgAsset('assets/icons/os/unknown_os.svg'),
};

final Map<Browser, SvgPicture> browserSvgIcons = {
  Browser.firefox: getSvgAsset('assets/icons/browsers/firefox.svg'),
  Browser.chromium: getSvgAsset('assets/icons/browsers/chromium.svg'),
  Browser.mobileSafari: getSvgAsset('assets/icons/browsers/safari.svg'),
  Browser.safari: getSvgAsset('assets/icons/browsers/safari.svg'),
  Browser.opera: getSvgAsset('assets/icons/browsers/opera.svg'),
  Browser.yandex: getSvgAsset('assets/icons/browsers/yandex.svg'),
  Browser.palemoon: getSvgAsset('assets/icons/browsers/palemoon.svg'),
  Browser.internetExplorer:
      getSvgAsset('assets/icons/browsers/internet_explorer.svg'),
  Browser.unknown: getSvgAsset('assets/icons/browsers/unknown_browser.svg'),
};

SvgPicture getSvgAsset(String path) {
  return SvgPicture.asset(
    path,
    width: 12,
    height: 12,
  );
}

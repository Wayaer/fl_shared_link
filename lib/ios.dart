part of 'fl_shared_link.dart';

class IOSAction {
  /// 通过打开一个url的方式打开其它的应用或链接、在支付或者分享时需要打开其他应用的方法
  static const String openURL = 'openURL';

  /// 是其它应用通过调用你的app中设置的URL scheme打开你的应用、例如做分享回调到自己app
  static const String handleOpenURL = 'handleOpenURL';

  /// NSUserActivityTypeBrowsingWeb 是通过浏览器域名打开app
  static const String browsingWeb = 'NSUserActivityTypeBrowsingWeb';
}

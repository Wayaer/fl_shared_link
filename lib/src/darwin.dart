part of '../fl_shared_link.dart';

/// iOS / macOS（Darwin）打开事件的类型常量。
///
/// 与 [IOSOpenUrlModel.action] 或 [IOSUniversalLinkModel.action] 对比使用。
class IOSAction {
  /// 通过打开 URL 的方式打开其它应用或链接。
  ///
  /// 对应 iOS 的 `openURL` 回调，以及 macOS 的自定义 URL Scheme 打开事件。
  static const String openURL = 'openURL';

  /// 其它应用通过调用宿主 App 配置的 URL Scheme 打开本 App。
  ///
  /// 对应 iOS 的 `handleOpenURL` 回调。
  static const String handleOpenURL = 'handleOpenURL';

  /// iOS 通过浏览器域名（Universal Link）打开 App。
  ///
  /// [IOSUniversalLinkModel.action] 的取值，对应
  /// `NSUserActivityTypeBrowsingWeb`。
  static const String browsingWeb = 'NSUserActivityTypeBrowsingWeb';

  /// macOS 通过 Finder「用其他应用打开」传入文件时的事件类型。
  ///
  /// 此时 [IOSOpenUrlModel.url] 为 `file://` 形式的文件 URL，
  /// 可配合 [FlSharedLink.externalFileCopyWithIOS] 拷贝文件。
  static const String openFile = 'openFile';
}

/// iOS Universal Link 数据模型。
///
/// 仅 iOS 支持；macOS 暂不转发 `NSUserActivity`，因此不会产生该模型。
class IOSUniversalLinkModel extends IOSOpenUrlModel {
  IOSUniversalLinkModel.fromMap(super.map)
      : title = map['title'] as String?,
        userInfo = map['userInfo'] as Map<dynamic, dynamic>?,
        super.fromMap();

  /// Universal Link 页面标题。
  String? title;

  /// `NSUserActivity.userInfo` 中携带的原始数据。
  ///
  /// 由业务方在生成 Universal Link 或页面跳转时写入，插件不做解析。
  dynamic userInfo;

  @override
  Map<String, dynamic> toMap() => {'title': title, 'userInfo': userInfo, ...super.toMap()};
}

/// iOS / macOS 通过 URL Scheme 或文件打开 App 时的数据模型。
///
/// - iOS：对应 `openURL` / `handleOpenURL` 回调；
/// - macOS：对应 `application(_:open:)` 回调，可能是自定义 Scheme，
///   也可能是 Finder 打开的文件。
class IOSOpenUrlModel extends BaseReceiveData {
  IOSOpenUrlModel.fromMap(super.map)
      : extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap();

  /// 打开事件附带的额外参数。
  ///
  /// iOS 下通常为 `UIApplication.OpenURLOptionsKey` 及其值；
  /// macOS 下暂无额外参数，返回 `null`。
  Map<dynamic, dynamic>? extras;

  @override
  Map<String, dynamic> toMap() => {'extras': extras, ...super.toMap()};
}

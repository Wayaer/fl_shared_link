import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef FlBeSharedAndroidReceiveDataModel = void Function(
    AndroidReceiveDataModel? data);

typedef FlBeSharedIOSUniversalLinkModel = void Function(
    IOSUniversalLinkModel? data);

typedef FlBeSharedIOSOpenUrlModel = void Function(IOSOpenUrlModel? data);

class FlBeShared {
  factory FlBeShared() => _singleton ??= FlBeShared._();

  FlBeShared._();

  static FlBeShared? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_be_shared');

  /// ******* Android ******* ///

  /// 获取 Android 分享 打开 接收到的内容
  Future<AndroidReceiveDataModel?> get receiveSharedWithAndroid async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMapMethod('getReceiveShared');
    if (data != null) return AndroidReceiveDataModel.fromMap(data);
    return null;
  }

  /// 获取 所有 Android Intent 数据
  Future<AndroidReceiveDataModel?> get intentWithAndroid async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMapMethod('getIntent');
    if (data != null) return AndroidReceiveDataModel.fromMap(data);
    return null;
  }

  /// [AndroidIntent] 中的 [url] 获取文件真是地址
  Future<String?> getRealFilePathWithAndroid() async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMethod<String>('getRealFilePath');
    return data;
  }

  /// [AndroidIntent] 中的 [url] 获取文件真是地址
  /// 兼容微信和QQ
  Future<String?> getRealFilePathCompatibleWXQQWithAndroid() async {
    if (!_isAndroid) return null;
    final data =
        await _channel.invokeMethod<String>('getRealFilePathCompatibleWXQQ');
    return data;
  }

  /// ******* IOS ******* ///

  /// 获取 ios universalLink 接收到的内容
  Future<IOSUniversalLinkModel?> get universalLinkWithIOS async {
    if (!_isIOS) return null;
    final data = await _channel.invokeMapMethod('getUniversalLinkMap');
    if (data != null) return IOSUniversalLinkModel.fromMap(data);
    return null;
  }

  /// 获取 ios openUrl 和 handleOpenUrl 接收到的内容
  Future<IOSOpenUrlModel?> get openUrlWithIOS async {
    if (!_isIOS) return null;
    final data = await _channel.invokeMapMethod('getOpenUrlMap');
    if (data != null) return IOSOpenUrlModel.fromMap(data);
    return null;
  }

  /// 监听 获取接收的内容
  /// app 首次启动 无法获取到数据，仅用于app进程没有被kill时 才会调用
  void receiveHandler({
    /// 监听 android 所有的Intent
    FlBeSharedAndroidReceiveDataModel? onAndroidIntent,

    /// 监听 android  分享到app 或者打开 app
    FlBeSharedAndroidReceiveDataModel? onReceiveShared,

    /// 监听 ios UniversalLink 启动 app
    FlBeSharedIOSUniversalLinkModel? onUniversalLink,

    /// 监听 ios openUrl 和 handleOpenUrl 启动 app
    /// 用 其他应用打开 分享 或 打开
    FlBeSharedIOSOpenUrlModel? onOpenUrl,
  }) {
    if (!_supportPlatform) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onIntent':
          onAndroidIntent
              ?.call(AndroidReceiveDataModel.fromMap(call.arguments as Map));
          break;
        case 'onReceiveShared':
          onReceiveShared
              ?.call(AndroidReceiveDataModel.fromMap(call.arguments as Map));
          break;
        case 'onOpenUrl':
          onOpenUrl?.call(IOSOpenUrlModel.fromMap(call.arguments as Map));
          break;
        case 'onUniversalLink':
          onUniversalLink
              ?.call(IOSUniversalLinkModel.fromMap(call.arguments as Map));
          break;
      }
    });
  }
}

class BaseReceiveData {
  BaseReceiveData.fromMap(Map<dynamic, dynamic> map)
      : url = map['url'] as String?,
        type = map['type'] as String?,
        scheme = map['scheme'] as String?;

  /// 接收到的url
  String? url;

  /// 接收事件类型
  /// IOS => ['openUrl,'handleOpenUrl']
  String? type;

  /// scheme
  String? scheme;

  Map<String, dynamic> toMap() => {'url': url, 'type': type, 'scheme': scheme};
}

class AndroidReceiveDataModel extends BaseReceiveData {
  AndroidReceiveDataModel.fromMap(Map<dynamic, dynamic> map)
      : action = map['action'] as String?,
        userInfo = map['userInfo'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap(map);

  /// 行为
  String? action;

  /// extras
  Map<dynamic, dynamic>? extras;

  /// userInfo
  String? userInfo;

  @override
  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({'action': action, 'userInfo': userInfo, 'extras': extras});
}

class IOSUniversalLinkModel extends IOSOpenUrlModel {
  IOSUniversalLinkModel.fromMap(Map<dynamic, dynamic> map)
      : title = map['title'] as String?,
        userInfo = map['userInfo'] as Map<dynamic, dynamic>?,
        super.fromMap(map);

  /// title
  String? title;

  dynamic userInfo;

  @override
  Map<String, dynamic> toMap() =>
      super.toMap()..addAll({'title': title, 'userInfo': userInfo});
}

class IOSOpenUrlModel extends BaseReceiveData {
  IOSOpenUrlModel.fromMap(Map<dynamic, dynamic> map)
      : relativePath = map['relativePath'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap(map);

  /// 相对地址
  String? relativePath;

  /// 其他的数据
  Map<dynamic, dynamic>? extras;

  @override
  Map<String, dynamic> toMap() =>
      super.toMap()..addAll({'relativePath': relativePath, 'extras': extras});
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

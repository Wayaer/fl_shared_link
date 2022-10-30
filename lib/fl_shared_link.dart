import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef FlSharedLinkAndroidReceiveDataModel = void Function(
    AndroidIntentModel? data);

typedef FlSharedLinkIOSUniversalLinkModel = void Function(
    IOSUniversalLinkModel? data);

typedef FlSharedLinkIOSOpenUrlModel = void Function(IOSOpenUrlModel? data);

class FlSharedLink {
  factory FlSharedLink() => _singleton ??= FlSharedLink._();

  FlSharedLink._();

  static FlSharedLink? _singleton;

  final MethodChannel _channel = const MethodChannel('fl.shared.link');

  /// ******* Android ******* ///

  /// 获取 所有 Android Intent 数据
  Future<AndroidIntentModel?> get intentWithAndroid async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMapMethod('getIntent');
    if (data != null) return AndroidIntentModel.fromMap(data);
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
    FlSharedLinkAndroidReceiveDataModel? onIntent,

    /// 监听 ios UniversalLink 启动 app
    FlSharedLinkIOSUniversalLinkModel? onUniversalLink,

    /// 监听 ios openUrl 和 handleOpenUrl 启动 app
    /// 用 其他应用打开 分享 或 打开
    FlSharedLinkIOSOpenUrlModel? onOpenUrl,
  }) {
    if (!_supportPlatform) return;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onIntent':
          onIntent?.call(AndroidIntentModel.fromMap(call.arguments as Map));
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
        action = map['action'] as String?,
        scheme = map['scheme'] as String?;

  /// 接收到的url
  String? url;

  /// 接收事件类型
  /// Android => action
  ///
  /// IOS => ['openUrl,'handleOpenUrl','NSUserActivityTypeBrowsingWeb']
  /// [action] = openURL 通过打开一个url的方式打开其它的应用或链接、在支付或者分享时需要打开其他应用的方法
  /// [action] = handleOpenURL 是其它应用通过调用你的app中设置的URL scheme打开你的应用、例如做分享回调到自己app
  /// [action] = NSUserActivityTypeBrowsingWeb 是通过浏览器域名打开app
  String? action;

  /// scheme
  String? scheme;

  Map<String, dynamic> toMap() =>
      {'url': url, 'action': action, 'scheme': scheme};
}

class AndroidIntentModel extends BaseReceiveData {
  AndroidIntentModel.fromMap(Map<dynamic, dynamic> map)
      : type = map['type'] as String?,
        userInfo = map['userInfo'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap(map);

  /// mimeType
  String? type;

  /// extras
  Map<dynamic, dynamic>? extras;

  /// userInfo
  String? userInfo;

  @override
  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({'type': type, 'userInfo': userInfo, 'extras': extras});
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
      : extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap(map);

  /// 其他的数据
  Map<dynamic, dynamic>? extras;

  @override
  Map<String, dynamic> toMap() => super.toMap()..addAll({'extras': extras});
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'android.dart';

part 'ios.dart';

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
  /// 兼容微信和QQ
  Future<String?> getRealFilePathWithAndroid(String id) async {
    if (!_isAndroid || id.isEmpty) return null;
    final data = await _channel.invokeMethod<String>(
        'getRealFilePathCompatibleWXQQ', id);
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

  /// 获取 ios launchingOptions 启动参数
  /// 只有启动的时候获取到参数
  Future<Map<dynamic, dynamic>?> get launchingOptionsWithIOS async {
    if (!_isIOS) return null;
    return await _channel.invokeMapMethod('getLaunchingOptionsMap');
  }

  /// 获取文件绝对路径
  Future<String?> getAbsolutePathWithIOS(String url) async {
    if (!_isIOS || url.isEmpty) return null;
    return await _channel.invokeMethod('getAbsolutePath', url);
  }

  /// 当文件路径带有中文时候 需要进行转码
  Future<String?> removingPercentEncodingWithIOS(String path) async {
    if (!_isIOS || path.isEmpty) return null;
    return await _channel.invokeMethod('removingPercentEncoding', path);
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
  /// Android => [AndroidAction]
  /// IOS => [IOSAction]
  String? action;

  /// scheme
  String? scheme;

  Map<String, dynamic> toMap() =>
      {'url': url, 'action': action, 'scheme': scheme};
}

class AndroidIntentModel extends BaseReceiveData {
  AndroidIntentModel.fromMap(super.map)
      : type = map['type'] as String?,
        userInfo = map['userInfo'] as String?,
        id = map['id'] as String?,
        authority = map['authority'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap();

  /// mimeType
  /// 部分 [AndroidMineType]
  String? type;

  /// extras
  Map<dynamic, dynamic>? extras;

  /// userInfo
  String? userInfo;

  /// authority
  String? authority;

  /// uri id
  /// 根据此 id 获取 uri 的真实路径
  String? id;

  @override
  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({
      'type': type,
      'userInfo': userInfo,
      'authority': authority,
      'extras': extras,
      'id': id
    });
}

class IOSUniversalLinkModel extends IOSOpenUrlModel {
  IOSUniversalLinkModel.fromMap(super.map)
      : title = map['title'] as String?,
        userInfo = map['userInfo'] as Map<dynamic, dynamic>?,
        super.fromMap();

  /// title
  String? title;

  dynamic userInfo;

  @override
  Map<String, dynamic> toMap() =>
      super.toMap()..addAll({'title': title, 'userInfo': userInfo});
}

class IOSOpenUrlModel extends BaseReceiveData {
  IOSOpenUrlModel.fromMap(super.map)
      : extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap();

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

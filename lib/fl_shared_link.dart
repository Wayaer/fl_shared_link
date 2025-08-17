import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/android.dart';

part 'src/harmonyos.dart';
part 'src/ios.dart';

typedef FlSharedLinkReceiveDataModel<T> = void Function(T data);

class FlSharedLink {
  factory FlSharedLink() => _singleton ??= FlSharedLink._();

  FlSharedLink._();

  static FlSharedLink? _singleton;

  static FlSharedLink get instance => FlSharedLink();

  final MethodChannel _channel = const MethodChannel('fl.shared.link');

  /// 清除缓存
  /// 支持 android ios harmonyos
  Future<bool> clearCache() async {
    if (!_supportPlatform) return false;
    return (await _channel.invokeMethod<bool>('clearCache')) ?? false;
  }

  /// 监听 获取接收的内容
  /// app 首次启动 无法获取到数据，仅用于app进程没有被kill时 才会调用
  /// 支持 android ios
  void receiveHandler({
    /// 监听 android 所有的Intent
    FlSharedLinkReceiveDataModel<AndroidIntentModel>? onIntent,

    /// 监听 ios UniversalLink 启动 app
    FlSharedLinkReceiveDataModel<IOSUniversalLinkModel>? onUniversalLink,

    /// 监听 ios openUrl 和 handleOpenUrl 启动 app
    /// 用 其他应用打开 分享 或 打开
    FlSharedLinkReceiveDataModel<IOSOpenUrlModel>? onOpenUrl,

    /// 监听 harmonyos 所有的 Want
    FlSharedLinkReceiveDataModel<HarmonyOSNewWantModel>? onWant,
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
        case 'onWant':
          onWant?.call(HarmonyOSNewWantModel.fromMap(call.arguments as Map));
          break;
      }
    });
  }

  /// ******* HarmonyOS ******* ///
  /// 获取 所有 HarmonyOS Want 数据
  Future<HarmonyOSWantModel?> get wantWithHarmonyOS async {
    if (!_isHarmonyOS) return null;
    final data = await _channel.invokeMapMethod('getWant');
    if (data != null) return HarmonyOSWantModel.fromMap(data);
    return null;
  }

  /// 获取 所有 HarmonyOS SharedData 数据
  Future<List<HarmonyOSSharedRecordModel>?> get wantSharedDataHarmonyOS async {
    if (!_isHarmonyOS) return null;
    final data = await _channel.invokeListMethod('getWantSharedData');
    if (data != null) {
      return data.map((e) => HarmonyOSSharedRecordModel.fromMap(e)).toList();
    }
    return null;
  }

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

  /// 外部导入的 Uri 文件 拷贝 到当前 app
  Future<String?> externalFileCopyWithIOS(String path) async {
    if (!_isIOS || path.isEmpty) return null;
    return await _channel.invokeMethod('externalFileCopy', path);
  }
}

class BaseReceiveData {
  BaseReceiveData.fromMap(Map<dynamic, dynamic> map)
      : url = map['url'] as String?,
        id = map['id'] as String?,
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

  /// uri id
  /// 根据此 id 获取 uri 的真实路径
  String? id;

  Map<String, dynamic> toMap() =>
      {'url': url, 'action': action, 'scheme': scheme, 'id': id};
}


bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS || _isHarmonyOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isHarmonyOS => defaultTargetPlatform.name == 'ohos';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

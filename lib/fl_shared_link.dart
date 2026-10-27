import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/android.dart';

part 'src/darwin.dart';

part 'src/harmonyos.dart';

/// 接收数据的回调函数签名。
///
/// [T] 为对应平台的数据模型，例如 [AndroidIntentModel]、[IOSOpenUrlModel]。
typedef FlSharedLinkReceiveDataModel<T> = void Function(T data);

/// 跨平台「应用被打开」信息读取插件。
///
/// 负责接收并解析 App 被其他应用或系统唤起时携带的数据：
///
/// - Android：`Intent`（分享、打开文件、URL Scheme 等）
/// - iOS / macOS：URL Scheme、iOS Universal Link，以及通过「用其他应用打开」传入的文件
/// - HarmonyOS：`Want`、`SharedData`
///
/// ## 基本用法
///
/// 1. 按照 README 完成宿主工程的平台配置（注册 Intent、URL Scheme、文档类型等）。
/// 2. App 启动后调用 [receiveHandler] 注册热启动监听。
/// 3. 冷启动（进程被杀死后重新拉起）场景，通过 [intentWithAndroid]、[openUrlWithIOS]、
///    [wantWithHarmonyOS] 等 getter 读取首次启动携带的数据。
///
/// ```dart
/// final FlSharedLink link = FlSharedLink();
///
/// // 冷启动：读取本次启动携带的数据
/// final AndroidIntentModel? intent = await link.intentWithAndroid;
///
/// // 热启动：监听后续被打开事件
/// link.receiveHandler(
///   onIntent: (AndroidIntentModel data) {},
///   onOpenUrl: (IOSOpenUrlModel data) {},
/// );
/// ```
///
/// 插件内部使用单例实现，重复调用 [FlSharedLink] 构造函数会返回同一个实例。
class FlSharedLink {
  /// 获取插件单例。
  factory FlSharedLink() => _instance;

  FlSharedLink._();

  static final FlSharedLink _instance = FlSharedLink._();

  /// 获取插件单例，与 [FlSharedLink] 构造函数等价。
  static FlSharedLink get instance => _instance;

  final MethodChannel _channel = const MethodChannel('fl.shared.link');

  /// 清除原生层缓存的启动与打开数据。
  ///
  /// 支持 Android、iOS、macOS、HarmonyOS。清除后：
  /// - [intentWithAndroid] / [openUrlWithIOS] / [universalLinkWithIOS] /
  ///   [wantWithHarmonyOS] 等 getter 将返回 `null`；
  /// - 已经拷贝到临时目录的文件不会被删除。
  ///
  /// 返回值 [bool] 表示是否清除成功；当前平台不支持时返回 `false`。
  Future<bool> clearCache() async {
    if (!_supportPlatform) return false;
    return (await _channel.invokeMethod<bool>('clearCache')) ?? false;
  }

  /// 注册「App 被再次打开」的监听。
  ///
  /// 该监听只在 App 进程未被杀死时触发：
  ///
  /// - Android：`onNewIntent` 回调（分享、打开文件、URL Scheme 等）
  /// - iOS / macOS：URL Scheme 回调（macOS 还会收到 Finder「用其他应用打开」的文件）
  /// - iOS：Universal Link 回调（macOS 暂不支持 Universal Link）
  /// - HarmonyOS：`onNewWant` 回调
  ///
  /// 冷启动时携带的数据请使用对应的 getter 读取，详见 [intentWithAndroid]、
  /// [openUrlWithIOS]、[universalLinkWithIOS]、[wantWithHarmonyOS]。
  ///
  /// 多次调用会替换上一次注册的回调；某平台不支持时，对应回调不会被触发。
  void receiveHandler({
    /// 监听 Android 的所有 Intent。
    ///
    /// 分享、打开文件、URL Scheme 等事件都会在这里回调。
    FlSharedLinkReceiveDataModel<AndroidIntentModel>? onIntent,

    /// 监听 iOS Universal Link 启动 App。
    ///
    /// 仅 iOS 支持；macOS 不会触发。
    FlSharedLinkReceiveDataModel<IOSUniversalLinkModel>? onUniversalLink,

    /// 监听 iOS / macOS 通过 URL Scheme 或「用其他应用打开」启动 App。
    ///
    /// [IOSOpenUrlModel.action] 可用于区分具体来源，参考 [IOSAction]。
    FlSharedLinkReceiveDataModel<IOSOpenUrlModel>? onOpenUrl,

    /// 监听 HarmonyOS 的所有 Want 数据。
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
          onUniversalLink?.call(IOSUniversalLinkModel.fromMap(call.arguments as Map));
          break;
        case 'onWant':
          onWant?.call(HarmonyOSNewWantModel.fromMap(call.arguments as Map));
          break;
      }
    });
  }

  /// ******* HarmonyOS ******* ///

  /// 获取本次启动对应的 HarmonyOS `Want`。
  ///
  /// 仅 HarmonyOS 支持。冷启动与热启动都会覆盖到最近一次 `Want`。
  Future<HarmonyOSWantModel?> get wantWithHarmonyOS async {
    if (!_isHarmonyOS) return null;
    final data = await _channel.invokeMapMethod('getWant');
    if (data != null) return HarmonyOSWantModel.fromMap(data);
    return null;
  }

  /// 获取 HarmonyOS 分享数据（`SharedData`）记录列表。
  ///
  /// 仅 HarmonyOS 支持。数据来源于当前 `Want`，通常包含文本、链接、文件 URI 等。
  /// 需要在收到分享后调用；没有分享数据时返回 `null`。
  Future<List<HarmonyOSSharedRecordModel>?> get wantSharedDataWithHarmonyOS async {
    if (!_isHarmonyOS) return null;
    final data = await _channel.invokeListMethod('getWantSharedData');
    if (data != null) {
      return data.map((e) => HarmonyOSSharedRecordModel.fromMap(e)).toList();
    }
    return null;
  }

  /// 将 HarmonyOS 沙盒路径转换为 `file://` 形式的 URI。
  ///
  /// 仅 HarmonyOS 支持；[path] 为空或当前平台不支持时返回 `null`。
  Future<String?> getUriFromPathWithHarmonyOS(String path) async {
    if (!_isHarmonyOS || path.isEmpty) return null;
    return await _channel.invokeMethod<String>('getUriFromPath', {'path': path});
  }

  /// 将 HarmonyOS 外部 URI 指向的文件拷贝到应用沙盒缓存目录。
  ///
  /// 仅 HarmonyOS 支持。适用于分享得到的 URI 需要长期访问的场景，
  /// 返回拷贝后的本地绝对路径；失败或平台不支持时返回 `null`。
  Future<String?> uriCopyToCachePathWithHarmonyOS(String uri) async {
    if (!_isHarmonyOS || uri.isEmpty) return null;
    return (await _channel.invokeMethod<String>('uriCopyToCachePath', {'uri': uri}));
  }

  /// ******* Android ******* ///

  /// 获取本次启动对应的 Android `Intent`。
  ///
  /// 仅 Android 支持。包含分享（`ACTION_SEND`）、打开文件（`ACTION_VIEW`）等事件；
  /// 没有可用 Intent 时返回 `null`。
  Future<AndroidIntentModel?> get intentWithAndroid async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMapMethod('getIntent');
    if (data != null) return AndroidIntentModel.fromMap(data);
    return null;
  }

  /// 将 [intentWithAndroid] 返回的 [AndroidIntentModel.id] 解析为真实文件路径。
  ///
  /// 仅 Android 支持，兼容微信、QQ 等通过 `content://` 分享文件的场景：
  /// 插件会把文件拷贝到应用私有缓存目录，并返回可读的绝对路径。
  ///
  /// [id] 为空、没有对应记录或解析失败时返回 `null`。
  Future<String?> getRealFilePathWithAndroid(String id) async {
    if (!_isAndroid || id.isEmpty) return null;
    final data = await _channel.invokeMethod<String>('getRealFilePathWithAndroid', id);
    return data;
  }

  /// ******* iOS / macOS（Darwin） ******* ///

  /// 获取 iOS Universal Link 接收到的内容。
  ///
  /// 仅 iOS 支持。macOS 不提供 Universal Link 转发，因此返回 `null`。
  Future<IOSUniversalLinkModel?> get universalLinkWithIOS async {
    if (!_isIOS) return null;
    final data = await _channel.invokeMapMethod('getUniversalLinkMap');
    if (data != null) return IOSUniversalLinkModel.fromMap(data);
    return null;
  }

  /// 获取 iOS / macOS 通过 URL Scheme 或「用其他应用打开」接收到的内容。
  ///
  /// - iOS：来自 `openURL` 或 `handleOpenURL` 生命周期回调；
  /// - macOS：来自 `application(_:open:)`，既包含自定义 URL Scheme，也包含 Finder 打开的文件。
  ///
  /// 可通过返回值的 [IOSOpenUrlModel.action] 判断具体来源，参考 [IOSAction]。
  /// 没有数据时返回 `null`。
  Future<IOSOpenUrlModel?> get openUrlWithIOS async {
    if (!_isDarwin) return null;
    final data = await _channel.invokeMapMethod('getOpenUrlMap');
    if (data != null) return IOSOpenUrlModel.fromMap(data);
    return null;
  }

  /// 获取 iOS 冷启动时的 `launchingOptions`。
  ///
  /// 仅 iOS 支持，且只有首次启动能够获取到参数。macOS 返回 `null`。
  ///
  /// 返回值为系统原始 `launchOptions` 转换后的 `Map`，键值均为字符串，
  /// 便于跨平台传输；需要原始对象时请在原生侧自行读取。
  Future<Map<dynamic, dynamic>?> get launchingOptionsWithIOS async {
    if (!_isIOS) return null;
    return await _channel.invokeMapMethod('getLaunchingOptionsMap');
  }

  /// 获取文件绝对路径。
  ///
  /// 支持 iOS 与 macOS：
  /// - iOS：支持 `file://` 路径、相册资源标识符（`PHAsset.localIdentifier`），
  ///   相册资源需要宿主工程配置 `NSPhotoLibraryUsageDescription`；
  /// - macOS：支持 `file://` 路径与普通文件路径。
  ///
  /// 无法解析时返回 `null`。
  Future<String?> getAbsolutePathWithIOS(String url) async {
    if (!_isDarwin || url.isEmpty) return null;
    return await _channel.invokeMethod('getAbsolutePath', url);
  }

  /// 将外部导入的文件拷贝到当前 App 的沙盒临时目录。
  ///
  /// 支持 iOS 与 macOS。传入 [openUrlWithIOS] 或 [universalLinkWithIOS] 返回模型中的
  /// [BaseReceiveData.id]，插件会在原生侧根据 id 找到对应 URL 并拷贝文件。
  ///
  /// 返回拷贝后的文件绝对路径；源文件不存在、无访问权限或平台不支持时返回 `null`。
  /// 对于沙盒环境下的 macOS App，需在 entitlements 中开启文件访问权限。
  Future<String?> externalFileCopyWithIOS(String id) async {
    if (!_isDarwin || id.isEmpty) return null;
    return await _channel.invokeMethod('externalFileCopy', id);
  }
}

/// 各平台「被打开」事件的数据基类。
///
/// 各平台的具体模型继承自该类，公共字段含义如下：
class BaseReceiveData {
  BaseReceiveData.fromMap(Map<dynamic, dynamic> map)
      : url = map['url'] as String?,
        id = map['id'] as String?,
        action = map['action'] as String?,
        scheme = map['scheme'] as String?;

  /// 接收到的 URL。
  ///
  /// - Android：通常是 `file://` 或 `content://` 路径；
  /// - iOS / macOS：`openUrl`、`Universal Link` 或文件 URL。
  String? url;

  /// 接收事件的类型，用于区分同一个平台下的不同来源。
  ///
  /// Android 参考 [AndroidAction]；iOS / macOS 参考 [IOSAction]。
  String? action;

  /// URL 的 Scheme，例如 `file`、`content`、`https` 或自定义 Scheme。
  String? scheme;

  /// 事件的唯一标识。
  ///
  /// 主要用于 Android [FlSharedLink.getRealFilePathWithAndroid] 与
  /// iOS / macOS [FlSharedLink.externalFileCopyWithIOS] 定位对应的 URI。
  String? id;

  /// 将当前模型转换为 `Map`，便于日志输出或二次序列化。
  Map<String, dynamic> toMap() => {'url': url, 'action': action, 'scheme': scheme, 'id': id};
}

/// 当前平台是否受插件支持。
bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isDarwin || _isHarmonyOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isHarmonyOS => defaultTargetPlatform.name == 'ohos';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

/// iOS 与 macOS 共用同一套原生实现，这里统一判断。
bool get _isDarwin => _isIOS || defaultTargetPlatform == TargetPlatform.macOS;

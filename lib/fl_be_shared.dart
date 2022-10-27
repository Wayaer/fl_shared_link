import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef FlBeSharedReceiveData = void Function(AndroidIntent? data);

class FlBeShared {
  factory FlBeShared() => _singleton ??= FlBeShared._();

  FlBeShared._();

  static FlBeShared? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_be_shared');

  /// 获取接收到的内容
  Future<AndroidIntent?> get receiveShared async {
    final data = await _channel.invokeMapMethod('getReceiveShared');
    if (data != null) return AndroidIntent.fromMap(data);
    return null;
  }

  /// 获取 所有 Android Intent 数据
  Future<AndroidIntent?> get androidIntent async {
    if (!_isAndroid) return null;
    final data = await _channel.invokeMapMethod('getIntent');
    debugPrint(data.toString());
    if (data != null) return AndroidIntent.fromMap(data);
    return null;
  }

  /// [AndroidIntent] 中的 [data] 获取文件真是地址
  Future<String?> getRealFilePathWithAndroid() async {
    final data = await _channel.invokeMethod<String>('getRealFilePath');
    debugPrint(data.toString());
    return data;
  }

  /// [AndroidIntent] 中的 [data] 获取文件真是地址
  /// 兼容微信和QQ
  Future<String?> getRealFilePathCompatibleWXQQWithAndroid() async {
    final data =
        await _channel.invokeMethod<String>('getRealFilePathCompatibleWXQQ');
    debugPrint(data.toString());
    return data;
  }

  /// 监听 获取接收的内容
  /// app 首次启动 无法获取到数据，仅用于app进程没有被kill时 才会调用
  void receiveHandler({
    /// 监听android 所有的Intent
    FlBeSharedReceiveData? onAndroidIntent,
    FlBeSharedReceiveData? onReceiveShared,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onIntent") {
        onAndroidIntent?.call(AndroidIntent.fromMap(call.arguments as Map));
      } else if (call.method == "onReceiveShared") {
        debugPrint('onReceiveShared====');
        onReceiveShared?.call(AndroidIntent.fromMap(call.arguments as Map));
      }
    });
  }
}

class AndroidIntent {
  AndroidIntent.fromMap(Map<dynamic, dynamic> map)
      : data = map['data'] as String?,
        type = map['type'] as String?,
        action = map['action'] as String?,
        dataString = map['dataString'] as String?,
        scheme = map['scheme'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?;

  /// 接收到的内容
  String? data;

  /// 接收事件类型
  String? type;

  /// 行动
  String? action;
  String? dataString;

  ///
  String? scheme;

  ///
  Map<dynamic, dynamic>? extras;

  Map<String, dynamic> toMap() => {
        'data': data,
        'action': action,
        'type': type,
        'dataString': dataString,
        'scheme': scheme,
        'extras': extras
      };
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

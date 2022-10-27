import 'package:flutter/services.dart';

typedef FlBeSharedReceiveData = void Function(ReceiveData? data);

class FlBeShared {
  factory FlBeShared() => _singleton ??= FlBeShared._();

  FlBeShared._();

  static FlBeShared? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_be_shared');

  /// 获取接收到的内容
  Future<ReceiveData?> get receiveData async {
    final data = await _channel.invokeMapMethod('getReceiveData');
    if (data != null) return ReceiveData.fromMap(data);
    return null;
  }

  /// 监听 获取接收的内容
  /// app 首次启动 无法获取到数据，仅用于app进程没有被kill时 才会调用
  void receiveHandler({FlBeSharedReceiveData? receiveData}) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "receive") {
        receiveData?.call(ReceiveData.fromMap(call.arguments as Map));
      }
    });
  }
}

class ReceiveData {
  ReceiveData.fromMap(Map<dynamic, dynamic> map)
      : action = map['action'] as String?,
        data = map['data'] as String?;

  /// 接收到的内容
  String? data;

  /// 接收事件类型
  String? action;

  Map<String, dynamic> toMap() => {'data': data, 'action': action};
}

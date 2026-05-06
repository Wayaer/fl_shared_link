part of '../fl_shared_link.dart';

enum HarmonyOSLaunchReason {
  /// 未知原因
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @crossplatform
  /// @since 10
  /// @atomicservice
  /// @since 11
  unknown,

  /// 通过 startAbility 接口启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @atomicservice
  /// @since 11
  startAbility,

  /// 通过 startAbilityByCall 接口启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @atomicservice
  /// @since 11
  call,

  /// 通过跨端设备迁移启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @atomicservice
  /// @since 11
  continuation,

  /// 应用恢复后，应用故障时自动恢复并启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @atomicservice
  /// @since 11
  appRecovery,

  /// 通过 acquireShareData 接口启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  share,

  /// 通过开机启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 11
  autoStartup,

  /// 通过洞察意图接口启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @atomicservice
  /// @since 11
  insightIntent,

  /// 通过跨端设备迁移准备启动能力
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @atomicservice
  /// @since 12
  prepareContinuation;

  /// 根据整数数值获取对应的枚举值
  /// 若数值不匹配任何枚举，返回 unknown
  static HarmonyOSLaunchReason fromInt(num value) {
    if (value < 0 || value >= values.length) {
      return unknown;
    }
    return values[value.toInt()];
  }
}

enum HarmonyOSLaunchLastExitReason {
  /// 退出原因：未知。应用框架中未记录目标应用上次退出的原因
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @crossplatform
  /// @since 10
  /// @atomicservice
  /// @since 11
  unknown,

  /// 退出原因：能力未响应（已废弃）
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @deprecated since 10
  /// @useinstead AbilityConstant.LastExitReason#APP_FREEZE
  abilityNotResponding,

  /// 退出原因：正常退出。因用户主动关闭导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 9
  /// @atomicservice
  /// @since 11
  normal,

  /// 退出原因：C++ 崩溃。因原生异常信号导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  cppCrash,

  /// 退出原因：JS 错误。因 JS 错误导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  jsError,

  /// 退出原因：应用冻结。因应用冻结错误导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  appFreeze,

  /// 退出原因：性能控制。因系统性能问题（如设备内存不足）导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  performanceControl,

  /// 退出原因：资源控制。因资源使用违规（如超出 CPU/IO/内存使用限制）导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  resourceControl,

  /// 退出原因：应用升级。因应用升级导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @since 10
  /// @atomicservice
  /// @since 11
  upgrade,

  /// 退出原因：用户请求。因用户请求导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @atomicservice
  /// @since 18
  userRequest,

  /// 退出原因：系统信号。因系统信号导致应用退出
  ///
  /// @syscap SystemCapability.Ability.AbilityRuntime.Core
  /// @stagemodelonly
  /// @atomicservice
  /// @since 18
  signal;

  /// 根据整数数值获取对应的退出原因枚举
  /// 利用 values 数组下标映射原始数值，超出范围返回 unknown
  static HarmonyOSLaunchLastExitReason fromInt(num value) {
    if (value >= 0 && value < values.length) {
      return values[value.toInt()];
    }
    return unknown;
  }
}

class HarmonyOSNewWantModel {
  /// 要启动的应用的Want信息。
  final HarmonyOSWantModel? want;

  /// 启动参数。
  final HarmonyOSLaunchParamsModel? launchParams;

  HarmonyOSNewWantModel({this.want, this.launchParams});

  factory HarmonyOSNewWantModel.fromMap(Map<dynamic, dynamic> map) =>
      HarmonyOSNewWantModel(
          want: map['want'] == null
              ? null
              : HarmonyOSWantModel.fromMap(
                  map['want'] as Map<dynamic, dynamic>),
          launchParams: map['launchParams'] == null
              ? null
              : HarmonyOSLaunchParamsModel.fromMap(
                  map['launchParams'] as Map<dynamic, dynamic>));

  Map<String, dynamic> toMap() => {
        'want': want?.toMap(),
        'launchParams': launchParams?.toMap(),
      };
}

class HarmonyOSLaunchParamsModel {
  /// 启动原因。
  final HarmonyOSLaunchReason? launchReason;

  /// 启动原因。
  final String? launchReasonMessage;

  /// 上次退出原因。
  final HarmonyOSLaunchLastExitReason? lastExitReason;

  /// 上次退出原因。
  final String? lastExitMessage;

  /// 上次退出详情。
  final HarmonyOSLaunchLastExitDetailInfoModel? lastExitDetailInfo;

  HarmonyOSLaunchParamsModel({
    this.launchReason,
    this.launchReasonMessage,
    this.lastExitReason,
    this.lastExitMessage,
    this.lastExitDetailInfo,
  });

  factory HarmonyOSLaunchParamsModel.fromMap(Map<dynamic, dynamic> map) =>
      HarmonyOSLaunchParamsModel(
        launchReason:
            HarmonyOSLaunchReason.fromInt(map['launchReason'] as num? ?? 0),
        launchReasonMessage: map['launchReasonMessage'] as String?,
        lastExitReason: HarmonyOSLaunchLastExitReason.fromInt(
            map['lastExitReason'] as num? ?? 0),
        lastExitMessage: map['lastExitMessage'] as String?,
        lastExitDetailInfo: map['lastExitDetailInfo'] == null
            ? null
            : HarmonyOSLaunchLastExitDetailInfoModel.fromMap(
                map['lastExitDetailInfo'] as Map<dynamic, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'launchReason': launchReason,
        'launchReasonMessage': launchReasonMessage,
        'lastExitReason': lastExitReason,
        'lastExitMessage': lastExitMessage,
        'lastExitDetailInfo': lastExitDetailInfo?.toMap(),
      };
}

class HarmonyOSWantModel {
  /// 应用包名。
  final String? bundleName;

  /// ability 名称。
  final String? abilityName;

  /// 设备ID。
  final String? deviceId;

  /// 要启动的Ability的URI。
  /// 例如：“ability://com.example.myapplication.MainAbility”
  final String? uri;

  /// 要启动的Ability的MIME类型。
  final String? type;

  /// 要启动的Ability的启动标志。
  final num? flags;

  /// 要启动的Ability的操作。
  final String? action;

  /// 要启动的Ability的实体。
  final List<String>? entities;

  /// 要启动的Ability的模块名称。
  final String? moduleName;

  HarmonyOSWantModel.fromMap(Map<dynamic, dynamic> map)
      : bundleName = map['bundleName'] as String?,
        abilityName = map['abilityName'] as String?,
        deviceId = map['deviceId'] as String?,
        uri = map['uri'] as String?,
        type = map['type'] as String?,
        flags = map['flags'] as int?,
        action = map['action'] as String?,
        entities = (map['entities'] as List?)?.map((e) => e as String).toList(),
        moduleName = map['moduleName'] as String?;

  Map<String, dynamic> toMap() => {
        'bundleName': bundleName,
        'abilityName': abilityName,
        'deviceId': deviceId,
        'uri': uri,
        'type': type,
        'flags': flags,
        'action': action,
        'entities': entities,
        'moduleName': moduleName,
      };
}

class HarmonyOSLaunchLastExitDetailInfoModel {
  final num? pid;
  final String? processName;
  final num? uid;
  final num? exitSubReason;
  final String? exitMsg;
  final num? rss;
  final num? pss;
  final num? timestamp;

  HarmonyOSLaunchLastExitDetailInfoModel.fromMap(Map<dynamic, dynamic> map)
      : pid = map['pid'] as num?,
        processName = map['processName'] as String?,
        uid = map['uid'] as num?,
        exitSubReason = map['exitSubReason'] as num?,
        exitMsg = map['exitMsg'] as String?,
        rss = map['rss'] as num?,
        pss = map['pss'] as num?,
        timestamp = map['timestamp'] as num?;

  Map<String, dynamic> toMap() => {
        'pid': pid,
        'processName': processName,
        'uid': uid,
        'exitSubReason': exitSubReason,
        'exitMsg': exitMsg,
        'rss': rss,
        'pss': pss,
        'timestamp': timestamp,
      };
}

/// 鸿蒙系统共享记录模型类
/// 对应 TypeScript 中的 SharedRecord 接口
class HarmonyOSSharedRecordModel {
  /// 指示共享记录的统一类型描述符
  /// 详情参见 {@link @ohos.data.uniformTypeDescriptor}
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String utd;

  /// 共享记录的内容，不需要授权的信息
  /// 包括但不限于文本、HTML文本和URL
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String? content;

  /// 共享记录的URI
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String? uri;

  /// 共享记录的标题
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String? title;

  /// 共享记录的标签
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String? label;

  /// 共享记录的描述
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final String? description;

  /// 共享记录的缩略图
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final Uint8List? thumbnail;

  /// 共享记录的缩略图URI
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 5.0.0(12)
  final String? thumbnailUri;

  /// 共享记录的额外数据
  /// 内容将转发到目标应用，无需权限授权
  ///
  /// @syscap SystemCapability.Collaboration.SystemShare
  /// @stagemodelonly
  /// @since 4.1.0(11)
  final Map<dynamic, dynamic>? extraData;

  HarmonyOSSharedRecordModel.fromMap(Map<dynamic, dynamic> map)
      : utd = map['utd'] as String,
        content = map['content'] as String?,
        uri = map['uri'] as String?,
        title = map['title'] as String?,
        label = map['label'] as String?,
        description = map['description'] as String?,
        thumbnail = map['thumbnail'] as Uint8List?,
        thumbnailUri = map['thumbnailUri'] as String?,
        extraData = map['extraData'] as Map<dynamic, dynamic>?;

  /// 将当前实例转换为 Map
  /// 返回包含所有属性的映射表，便于序列化和传输
  Map<String, dynamic> toMap() => {
        'utd': utd,
        'content': content,
        'uri': uri,
        'title': title,
        'label': label,
        'description': description,
        'thumbnail': thumbnail,
        'thumbnailUri': thumbnailUri,
        'extraData': extraData,
      };
}

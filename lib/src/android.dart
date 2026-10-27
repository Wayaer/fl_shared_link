part of '../fl_shared_link.dart';

/// Android `Intent` 数据模型。
///
/// 覆盖分享（`ACTION_SEND`）、打开文件（`ACTION_VIEW`）、URL Scheme 等场景，
/// 可通过 [action]、[type]、[url]、[scheme] 等字段判断当前事件的来源。
class AndroidIntentModel extends BaseReceiveData {
  AndroidIntentModel.fromMap(super.map)
      : type = map['type'] as String?,
        userInfo = map['userInfo'] as String?,
        authority = map['authority'] as String?,
        extras = map['extras'] as Map<dynamic, dynamic>?,
        super.fromMap();

  /// Intent 的 MIME 类型，例如 `image/*`、`application/pdf`。
  ///
  /// 常见取值可参考 [AndroidMineType]；通过 URL Scheme 打开时可能为 `null`。
  String? type;

  /// Intent 附带的 `extras` 数据。
  ///
  /// 例如微信分享时携带的 `android.intent.extra.TEXT`、`android.intent.extra.STREAM` 等。
  Map<dynamic, dynamic>? extras;

  /// `content://` URI 的 `userInfo` 部分。
  ///
  /// 一般用于定位 URI 的来源，可能为 `null`。
  String? userInfo;

  /// `content://` URI 的 authority（主机名部分）。
  ///
  /// 例如 `com.tencent.mm.external.fileprovider`，可据此判断分享来源应用。
  String? authority;

  @override
  Map<String, dynamic> toMap() => {
        'type': type,
        'userInfo': userInfo,
        'authority': authority,
        'extras': extras,
        ...super.toMap(),
      };
}

/// Android `Intent.action` 常量。
///
/// 完整列表可参考
/// [Android Intent 文档](https://developer.android.com/reference/android/content/Intent)。
/// 分享场景常用 [send]；打开文件、URL Scheme 场景常用 [view]。
class AndroidAction {
  AndroidAction._();

  /// 打开所有应用列表。
  static const String allApps = 'android.intent.action.ALL_APPS';

  /// 处理来电。
  static const String answer = 'android.intent.action.ANSWER';

  /// 应用发生错误。
  static const String appError = 'android.intent.action.APP_ERROR';

  /// 打开应用的设置页面。
  static const String applicationPreferences = 'android.intent.action.APPLICATION_PREFERENCES';

  /// 启动语音助手。
  static const String assist = 'android.intent.action.ASSIST';

  /// 为某条数据附加内容。
  static const String attachData = 'android.intent.action.ATTACH_DATA';

  /// 自动撤销权限。
  static const String autoRevokePermissions = 'android.intent.action.AUTO_REVOKE_PERMISSIONS';

  /// 提交 Bug 报告。
  static const String bugReport = 'android.intent.action.BUG_REPORT';

  /// 直接拨打电话。
  static const String call = 'android.intent.action.CALL';

  /// 打开拨号盘。
  static const String callButton = 'android.intent.action.CALL_BUTTON';

  /// 运营商配置。
  static const String carrierSetup = 'android.intent.action.CARRIER_SETUP';

  /// 显示应用选择器。
  static const String chooser = 'android.intent.action.CHOOSER';

  /// 创建文档。
  static const String createDocument = 'android.intent.action.CREATE_DOCUMENT';

  /// 创建提醒。
  static const String createReminder = 'android.intent.action.CREATE_REMINDER';

  /// 创建桌面快捷方式。
  static const String createShortcut = 'android.intent.action.CREATE_SHORTCUT';

  /// 自定义动作定义。
  static const String define = 'android.intent.action.DEFINE';

  /// 删除数据。
  static const String delete = 'android.intent.action.DELETE';

  /// 打开拨号界面并填入号码。
  static const String dial = 'android.intent.action.DIAL';

  /// 编辑数据。
  static const String edit = 'android.intent.action.EDIT';

  /// 工厂测试。
  static const String factoryTest = 'android.intent.action.FACTORY_TEST';

  /// 获取内容。
  static const String getContent = 'android.intent.action.GET_CONTENT';

  /// 插入数据。
  static const String insert = 'android.intent.action.INSERT';

  /// 插入或编辑数据。
  static const String insertOrEdit = 'android.intent.action.INSERT_OR_EDIT';

  /// 安装失败。
  static const String installFailure = 'android.intent.action.INSTALL_FAILURE';

  /// 安装应用。
  static const String installPackage = 'android.intent.action.INSTALL_PACKAGE';

  /// 应用入口。
  static const String main = 'android.intent.action.MAIN';

  /// 管理网络使用情况。
  static const String manageNetworkUsage = 'android.intent.action.MANAGE_NETWORK_USAGE';

  /// 管理未使用的应用。
  static const String manageUnusedApps = 'android.intent.action.MANAGE_UNUSED_APPS';

  /// 打开文档。
  static const String openDocument = 'android.intent.action.OPEN_DOCUMENT';

  /// 打开文档目录。
  static const String openDocumentTree = 'android.intent.action.OPEN_DOCUMENT_TREE';

  /// 粘贴数据。
  static const String paste = 'android.intent.action.PASTE';

  /// 选择数据。
  static const String pick = 'android.intent.action.PICK';

  /// 选择 Activity。
  static const String pickActivity = 'android.intent.action.PICK_ACTIVITY';

  /// 电量使用情况。
  static const String powerUsageSummary = 'android.intent.action.POWER_USAGE_SUMMARY';

  /// 处理文本。
  static const String processText = 'android.intent.action.PROCESS_TEXT';

  /// 快速查看。
  static const String quickView = 'android.intent.action.QUICK_VIEW';

  /// 运行。
  static const String run = 'android.intent.action.RUN';

  /// 分享数据。
  static const String send = 'android.intent.action.SEND';

  /// 搜索。
  static const String search = 'android.intent.action.SEARCH';

  /// 长按搜索。
  static const String searchLongPress = 'android.intent.action.SEARCH_LONG_PRESS';

  /// 分享多个数据。
  static const String sendMultiple = 'android.intent.action.SEND_MULTIPLE';

  /// 发送给指定目标。
  static const String sendTo = 'android.intent.action.SENDTO';

  /// 设置壁纸。
  static const String setWallpaper = 'android.intent.action.SET_WALLPAPER';

  /// 显示应用信息。
  static const String showAppInfo = 'android.intent.action.SHOW_APP_INFO';

  /// 同步数据。
  static const String sync = 'android.intent.action.SYNC';

  /// 系统教程。
  static const String systemTutorial = 'android.intent.action.SYSTEM_TUTORIAL';

  /// 翻译。
  static const String translate = 'android.intent.action.TRANSLATE';

  /// 卸载应用。
  static const String uninstallPackage = 'android.intent.action.UNINSTALL_PACKAGE';

  /// 查看数据，常用于打开文件或 URL Scheme。
  static const String view = 'android.intent.action.VIEW';

  /// 查看位置。
  static const String viewLocus = 'android.intent.action.VIEW_LOCUS';

  /// 查看权限使用情况。
  static const String viewPermissionUsage = 'android.intent.action.VIEW_PERMISSION_USAGE';

  /// 查看指定时间段内的权限使用情况。
  static const String viewPermissionUsageForPeriod = 'android.intent.action.VIEW_PERMISSION_USAGE_FOR_PERIOD';

  /// 语音命令。
  static const String voiceCommand = 'android.intent.action.VOICE_COMMAND';

  /// 网页搜索。
  static const String webSearch = 'android.intent.action.WEB_SEARCH';
}

/// Android MIME 类型常量（`Intent.type`）。
///
/// 用于在 `AndroidManifest.xml` 中声明可接收的文件类型，
/// 或与 [AndroidIntentModel.type] 进行比对。
/// 通用 MIME 规范可参考
/// [IANA Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml)。
class AndroidMineType {
  AndroidMineType._();

  /// 音视频。
  static const String video = 'video/*';

  /// 音频。
  static const String audio = 'audio/*';

  /// 图片。
  static const String image = 'image/*';

  /// 文本。
  static const String text = 'text/*';

  /// 通用二进制流（`*`、`bin`、`class`、`exe` 等）。
  static const String octetStream = 'application/octet-stream';

  /// PDF。
  static const String pdf = 'application/pdf';

  /// PICS 规则。
  static const String picsRules = 'application/pics-rules';

  /// JavaScript。
  static const String javascript = 'application/x-javascript';

  /// ZIP。
  static const String zip = 'application/zip';

  /// ZIP（另一种注册方式）。
  static const String zipX = 'application/x-zip-compressed';

  /// RAR。
  static const String rar = 'application/rar';

  /// RAR（另一种注册方式）。
  static const String rarX = 'application/x-rar-compressed';

  /// JAR。
  static const String jar = 'application/java-archive';

  /// TAR。
  static const String tar = 'application/x-tar';

  /// TGZ。
  static const String tgz = 'application/x-compressed';

  /// POT / POS / PPT。
  static const String ppt = 'application/vnd.ms-powerpoint';

  /// XLS。
  static const String xls = 'application/vnd.ms-excel';

  /// DOC / DOT。
  static const String doc = 'application/msword';

  /// DOCX。
  static const String docx = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  /// DOTX。
  static const String dotx = 'application/vnd.openxmlformats-officedocument.wordprocessingml.template';

  /// POTX。
  static const String potx = 'application/vnd.openxmlformats-officedocument.presentationml.template';

  /// PPTX。
  static const String pptx = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

  /// XLSX。
  static const String xlsx = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  /// XLTX。
  static const String xltx = 'application/vnd.openxmlformats-officedocument.spreadsheetml.template';

  /// PPSX。
  static const String ppsx = 'application/vnd.openxmlformats-officedocument.presentationml.slideshow';
}

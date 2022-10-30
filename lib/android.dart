part of 'fl_shared_link.dart';

class AndroidAction {
  AndroidAction._();

  ///
  static const String allApps = 'android.intent.action.ALL_APPS';

  ///
  static const String answer = 'android.intent.action.ANSWER';

  ///
  static const String appError = 'android.intent.action.APP_ERROR';

  ///
  static const String applicationPreferences =
      'android.intent.action.APPLICATION_PREFERENCES';

  ///
  static const String assist = 'android.intent.action.ASSIST';

  ///
  static const String attachData = 'android.intent.action.ATTACH_DATA';

  ///
  static const String autoRevokePermissions =
      'android.intent.action.AUTO_REVOKE_PERMISSIONS';

  ///
  static const String bugReport = 'android.intent.action.BUG_REPORT';

  ///
  static const String call = 'android.intent.action.CALL';

  ///
  static const String callButton = 'android.intent.action.CALL_BUTTON';

  ///
  static const String carrierSetup = 'android.intent.action.CARRIER_SETUP';

  ///
  static const String chooser = 'android.intent.action.CHOOSER';

  ///
  static const String createDocument = 'android.intent.action.CREATE_DOCUMENT';

  ///
  static const String createReminder = 'android.intent.action.CREATE_REMINDER';

  ///
  static const String createShortcut = 'android.intent.action.CREATE_SHORTCUT';

  ///
  static const String define = 'android.intent.action.DEFINE';

  ///
  static const String delete = 'android.intent.action.DELETE';

  ///
  static const String dial = 'android.intent.action.DIAL';

  ///
  static const String edit = 'android.intent.action.EDIT';

  ///
  static const String factoryTest = 'android.intent.action.FACTORY_TEST';

  ///
  static const String getContent = 'android.intent.action.GET_CONTENT';

  ///
  static const String insert = 'android.intent.action.INSERT';

  ///
  static const String insertOrEdit = 'android.intent.action.INSERT_OR_EDIT';

  ///
  static const String installFailure = 'android.intent.action.INSTALL_FAILURE';

  ///
  static const String installPackage = 'android.intent.action.INSTALL_PACKAGE';

  ///
  static const String main = 'android.intent.action.MAIN';

  ///
  static const String manageNetworkUsage =
      'android.intent.action.MANAGE_NETWORK_USAGE';

  ///
  static const String manageUnusedApps =
      'android.intent.action.MANAGE_UNUSED_APPS';

  ///
  static const String openDocument = 'android.intent.action.OPEN_DOCUMENT';

  ///
  static const String openDocumentTree =
      'android.intent.action.OPEN_DOCUMENT_TREE';

  ///
  static const String paste = 'android.intent.action.PASTE';

  ///
  static const String pick = 'android.intent.action.PICK';

  ///
  static const String pickActivity = 'android.intent.action.PICK_ACTIVITY';

  ///
  static const String powerUsageSummary =
      'android.intent.action.POWER_USAGE_SUMMARY';

  ///
  static const String processText = 'android.intent.action.PROCESS_TEXT';

  ///
  static const String quickView = 'android.intent.action.QUICK_VIEW';

  ///
  static const String run = 'android.intent.action.RUN';

  ///
  static const String send = 'android.intent.action.SEND';

  ///
  static const String search = 'android.intent.action.SEARCH';

  ///
  static const String searchLongPress =
      'android.intent.action.SEARCH_LONG_PRESS';

  ///
  static const String sendMultiple = 'android.intent.action.SEND_MULTIPLE';

  ///
  static const String sendTo = 'android.intent.action.SENDTO';

  ///
  static const String setWallpaper = 'android.intent.action.SET_WALLPAPER';

  ///
  static const String showAppInfo = 'android.intent.action.SHOW_APP_INFO';

  ///
  static const String sync = 'android.intent.action.SYNC';

  ///
  static const String systemTutorial = 'android.intent.action.SYSTEM_TUTORIAL';

  ///
  static const String translate = 'android.intent.action.TRANSLATE';

  ///
  static const String uninstallPackage =
      'android.intent.action.UNINSTALL_PACKAGE';

  ///
  static const String view = 'android.intent.action.VIEW';

  ///
  static const String viewLocus = 'android.intent.action.VIEW_LOCUS';

  ///
  static const String viewPermissionUsage =
      'android.intent.action.VIEW_PERMISSION_USAGE';

  ///
  static const String viewPermissionUsageForPeriod =
      'android.intent.action.VIEW_PERMISSION_USAGE_FOR_PERIOD';

  ///
  static const String voiceCommand = 'android.intent.action.VOICE_COMMAND';

  ///
  static const String webSearch = 'android.intent.action.WEB_SEARCH';
}

class AndroidMineType {
  AndroidMineType._();

  /// Text：用于标准化地表示的文本信息，文本消息可以是多种字符集和或者多种格式的；
  /// Multipart：用于连接消息体的多个部分构成一个消息，这些部分可以是不同类型的数据；
  /// Application：用于传输应用程序数据或者二进制数据；
  /// Message：用于包装一个E-mail消息；
  /// Image：用于传输静态图片数据；
  /// Audio：用于传输音频或者音声数据；
  /// Video：用于传输动态影像数据，可以是与音频编辑在一起的视频数据格式。

  /// 音视频
  static const String video = "video/*";

  /// 音频
  static const String audio = "audio/*";

  /// 图片
  static const String image = "image/*";

  /// 文本
  static const String text = "text/*";

  /// *、bin、class dms、exe等
  static const String octetStream = "application/octet-stream";

  /// pdf
  static const String pdf = "application/pdf";

  /// prf
  static const String picsRules = "application/pics-rules";

  /// js
  static const String javascript = "application/x-javascript";

  /// zip
  static const String zip = "application/zip";

  /// zip
  static const String zipX = "application/x-zip-compressed";

  /// rar
  static const String rar = "application/rar";

  /// rar
  static const String rarX = "application/x-rar-compressed";

  /// jar
  static const String jva = "application/ava-archive";

  /// tar
  static const String tar = "application/x-tar";

  /// tgz
  static const String tgz = "application/x-compressed";

  /// pot pos ppt
  static const String ppt = "application/vnd.ms-powerpoint";

  /// xls
  static const String xls = "application/vnd.ms-excel";

  /// doc、dot
  static const String doc = "application/msword";

  /// docx
  static const String docx =
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

  /// dotx
  static const String dotx =
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template";

  /// potx
  static const String potx =
      "application/vnd.openxmlformats-officedocument.presentationml.template";

  /// pptx
  static const String pptx =
      "application/vnd.openxmlformats-officedocument.presentationml.presentation";

  /// xlsx
  static const String xlsx =
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

  /// xltx
  static const String xltx =
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template";

  /// ppsx
  static const String ppsx =
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow";
}

# fl_shared_link

[![pub version](https://img.shields.io/pub/v/fl_shared_link.svg)](https://pub.dev/packages/fl_shared_link)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

接收并解析 App 被其他应用或系统打开时携带的参数，支持 **Android**、**iOS**、**macOS** 与 **HarmonyOS**。

当用户把文件、链接或文本分享给应用，或通过 URL Scheme / Universal Link /「用其他应用打开」唤起应用时，
插件会把原生回调统一转换成 Dart 数据模型，方便业务侧直接读取。

## 功能特性

- Android：读取启动 `Intent`，支持分享、打开文件、自定义 URL Scheme，并可将 `content://` 文件解析为真实路径。
- iOS：读取 URL Scheme、Universal Link、冷启动参数，支持将外部文件拷贝到应用临时目录。
- macOS：读取 URL Scheme 与 Finder「用其他应用打开」传入的文件，支持文件拷贝。
- HarmonyOS：读取 `Want`、`NewWant`、分享数据（`SharedData`），支持 URI 转路径与文件拷贝。
- iOS 与 macOS 共享同一份原生实现（`darwin/fl_shared_link/Sources`），无需分别维护两套代码。
- 同时提供 CocoaPods 与 Swift Package Manager 接入方式。
- 统一的热启动监听入口 `receiveHandler`，以及冷启动数据读取 API。

## 平台支持

| 能力 | Android | iOS | macOS | HarmonyOS |
| --- | :---: | :---: | :---: | :---: |
| 冷启动参数 | ✅ `Intent` | ✅ URL / Universal Link / LaunchOptions | ✅ URL / 打开的文件 | ✅ `Want` |
| 热启动监听 | ✅ `onNewIntent` | ✅ URL / Universal Link | ✅ `application(_:open:)` | ✅ `onNewWant` |
| 分享文件 | ✅ | ✅ | ✅ | ✅ |
| 外部文件拷贝到沙盒 | ✅ 真实路径 | ✅ | ✅ | ✅ |
| Universal Link | - | ✅ | ❌ 暂不支持 | - |

> macOS 的 Universal Link 依赖 `NSUserActivity`，而 Flutter macOS 引擎暂未把该回调转发给插件；
> macOS 仅支持 URL Scheme 与 Finder 打开文件。

最低版本要求：Android `minSdk 24`，iOS 15.0+，macOS 12.0+，HarmonyOS 5.0+。

## 安装

```yaml
dependencies:
  fl_shared_link: ^0.5.0
```

```bash
flutter pub get
```

需要 Flutter 3.41 及以上版本（iOS UIScene 插件生命周期依赖 `FlutterSceneLifeCycleDelegate`）。

## 快速开始

```dart
import 'package:fl_shared_link/fl_shared_link.dart';

Future<void> initSharedLink() async {
  final FlSharedLink link = FlSharedLink();

  // 1. 注册热启动监听（App 进程未结束时触发）
  link.receiveHandler(
    onIntent: (AndroidIntentModel data) {
      debugPrint('Android Intent: ${data.toMap()}');
    },
    onOpenUrl: (IOSOpenUrlModel data) {
      debugPrint('iOS / macOS openUrl: ${data.toMap()}');
    },
    onUniversalLink: (IOSUniversalLinkModel data) {
      debugPrint('iOS Universal Link: ${data.toMap()}');
    },
    onWant: (HarmonyOSNewWantModel data) {
      debugPrint('HarmonyOS NewWant: ${data.toMap()}');
    },
  );

  // 2. 读取冷启动数据（进程被杀死后重新拉起）
  final AndroidIntentModel? intent = await link.intentWithAndroid;
  final IOSOpenUrlModel? openUrl = await link.openUrlWithIOS;
  final IOSUniversalLinkModel? universalLink = await link.universalLinkWithIOS;
  final HarmonyOSWantModel? want = await link.wantWithHarmonyOS;
}
```

> `receiveHandler` 只在 App 进程存活时触发；冷启动请通过对应的 getter 读取。
> 多次调用会替换上一次注册的回调。

## Android 配置

### 1. 注册分享 / 打开事件

在 `android/app/src/main/AndroidManifest.xml` 的 Activity 中添加 `intent-filter`：

```xml
<activity android:name=".MainActivity">
    <!-- 接收分享 -->
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="application/pdf" />
        <data android:mimeType="image/*" />
    </intent-filter>

    <!-- 接收「用其他应用打开」（微信、QQ 等） -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:scheme="file" />
        <data android:scheme="content" />
        <data android:mimeType="application/pdf" />
        <data android:mimeType="image/*" />
    </intent-filter>
</activity>
```

常用 MIME 类型可参考 `AndroidMineType`：

```xml
<intent-filter>
    <data android:mimeType="image/*" />
    <data android:mimeType="text/*" />
    <data android:mimeType="application/pdf" />
    <data android:mimeType="application/msword" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.wordprocessingml.document" />
    <data android:mimeType="application/vnd.ms-excel" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
    <data android:mimeType="application/vnd.ms-powerpoint" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.presentationml.presentation" />
</intent-filter>
```

### 2. 读取 Intent 与真实文件路径

```dart
final AndroidIntentModel? intent = await FlSharedLink().intentWithAndroid;
if (intent != null) {
  debugPrint('action: ${intent.action}');
  debugPrint('type: ${intent.type}');
  debugPrint('url: ${intent.url}');
  debugPrint('extras: ${intent.extras}');

  // 微信 / QQ 等通过 content:// 分享时，拷贝到应用缓存目录并返回绝对路径
  final String? realPath = await FlSharedLink().getRealFilePathWithAndroid(intent.id ?? '');
}
```

### 3. 避免分享列表中出现两个自己（可选）

部分应用（Telegram、邮件等）分享时可能误覆盖原应用。推荐把分享入口放到独立 Activity：

1. 将 `example/android/app/src/main/kotlin/fl/shared/link/example/SharedLauncherActivity.kt`
   复制到你的工程目录（与 `MainActivity` 同级）。
2. 在 `AndroidManifest.xml` 中注册 `SharedLauncherActivity`，并把分享 / 打开相关的
   `intent-filter` 从 `MainActivity` 移到该 Activity。
3. 若希望每次打开文件复用同一个任务栈，可将 `android:launchMode` 设为
   `singleInstancePerTask`。

## iOS 配置

在 `ios/Runner/Info.plist` 中声明可接收的文档类型与 URL Scheme：

```plist
<key>LSSupportsOpeningDocumentsInPlace</key>
<string>No</string>
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>FlSharedLink</string>
        <key>LSHandlerRank</key>
        <string>Default</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>public.file-url</string>
            <string>public.image</string>
            <string>public.text</string>
            <string>public.movie</string>
            <string>public.url</string>
            <string>public.data</string>
        </array>
    </dict>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>flsharedlink</string>
        </array>
    </dict>
</array>
```

- Universal Link：在 Apple Developer 中开启 Associated Domains，并在
  `ios/Runner/Runner.entitlements` 中添加 `applinks:你的域名`，服务端同时配置 AASA 文件。
- 相册资源解析：如使用 `getAbsolutePathWithIOS` 解析相册标识符，请在 `Info.plist` 中添加
  `NSPhotoLibraryUsageDescription`。

```dart
final IOSUniversalLinkModel? universalLink = await FlSharedLink().universalLinkWithIOS;
final IOSOpenUrlModel? openUrl = await FlSharedLink().openUrlWithIOS;
final Map<dynamic, dynamic>? launchOptions = await FlSharedLink().launchingOptionsWithIOS;

// openUrl / universalLink 的 id 可用于拷贝外部文件
final String? path = await FlSharedLink().externalFileCopyWithIOS(openUrl?.id ?? '');
```

> Flutter 3.29+ 的 iOS 工程默认启用 UIScene。插件已适配 `FlutterSceneLifeCycleDelegate`，
> 无需在 `AppDelegate` 中额外转发 URL 回调。

## macOS 配置

macOS 与 iOS 共用 `darwin/fl_shared_link/Sources/fl_shared_link/FlSharedLinkPlugin.swift`，只需配置宿主应用：

1. 在 `macos/Runner/Info.plist` 中声明文档类型与 URL Scheme（写法与 iOS 类似）。
2. 在 `macos/Runner/DebugProfile.entitlements` 与 `Release.entitlements` 中开启文件读取权限：

```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

3. 通过 Finder 的「用其他应用打开」或 `flsharedlink://` 唤起应用后，读取事件数据：

```dart
final IOSOpenUrlModel? openUrl = await FlSharedLink().openUrlWithIOS;
if (openUrl?.action == IOSAction.openFile) {
  final String? path = await FlSharedLink().externalFileCopyWithIOS(openUrl!.id ?? '');
}
```

> macOS 暂不支持 Universal Link；`universalLinkWithIOS` 与 `launchingOptionsWithIOS` 会返回 `null`。

## HarmonyOS 配置

在 `entry/src/main/module.json5` 的 `abilities` 中声明数据处理能力：

```json5
{
  "actions": [
    "ohos.want.action.viewData",
    "ohos.want.action.sendData"
  ],
  "uris": [
    {
      "scheme": "file",
      "utd": "general.entity",
      "maxFileSupported": 1
    },
    {
      "scheme": "file",
      "utd": "general.object",
      "maxFileSupported": 1
    }
  ]
}
```

- UTD 类型列表：<https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/uniform-data-type-list>
- `maxFileSupported` 为 0 表示不支持该类型文件的分享。

```dart
final HarmonyOSWantModel? want = await FlSharedLink().wantWithHarmonyOS;
final List<HarmonyOSSharedRecordModel>? records = await FlSharedLink().wantSharedDataWithHarmonyOS;

if (records != null && records.isNotEmpty) {
  final String? localPath = await FlSharedLink().uriCopyToCachePathWithHarmonyOS(records.first.uri ?? '');
}
```

## API 说明

| API | 支持平台 | 说明 |
| --- | --- | --- |
| `clearCache()` | 全部 | 清除原生层缓存的启动 / 打开数据，返回是否成功 |
| `receiveHandler(...)` | Android / iOS / macOS / HarmonyOS | 注册热启动监听，多次调用会覆盖 |
| `intentWithAndroid` | Android | 获取当前 `Intent` 数据 |
| `getRealFilePathWithAndroid(id)` | Android | 将 `content://` URI 拷贝并解析为真实路径 |
| `universalLinkWithIOS` | iOS | 获取 Universal Link 数据 |
| `openUrlWithIOS` | iOS / macOS | 获取 URL Scheme / 文件打开数据 |
| `launchingOptionsWithIOS` | iOS | 获取冷启动 `launchOptions` |
| `getAbsolutePathWithIOS(url)` | iOS / macOS | 解析文件绝对路径（iOS 支持相册标识符） |
| `externalFileCopyWithIOS(id)` | iOS / macOS | 按事件 id 拷贝外部文件到临时目录 |
| `wantWithHarmonyOS` | HarmonyOS | 获取当前 `Want` |
| `wantSharedDataWithHarmonyOS` | HarmonyOS | 获取分享记录列表 |
| `getUriFromPathWithHarmonyOS(path)` | HarmonyOS | 本地路径转 `file://` URI |
| `uriCopyToCachePathWithHarmonyOS(uri)` | HarmonyOS | 外部 URI 文件拷贝到沙盒缓存 |

### 数据模型

| 模型 | 说明 |
| --- | --- |
| `BaseReceiveData` | 公共字段：`url`、`id`、`action`、`scheme` |
| `AndroidIntentModel` | 额外包含 `type`、`extras`、`authority`、`userInfo` |
| `IOSOpenUrlModel` | 额外包含 `extras` |
| `IOSUniversalLinkModel` | 在 `IOSOpenUrlModel` 基础上增加 `title`、`userInfo` |
| `HarmonyOSWantModel` | `bundleName`、`abilityName`、`uri`、`type`、`action` 等 |
| `HarmonyOSNewWantModel` | `want` + `launchParams` |
| `HarmonyOSSharedRecordModel` | `utd`、`content`、`uri`、`title`、`thumbnail` 等 |

常量类：`AndroidAction`、`AndroidMineType`、`IOSAction`、`HarmonyOSLaunchReason`、
`HarmonyOSLaunchLastExitReason`。

## 示例工程

`example/` 展示了四个平台的完整接入方式，包括：

- 分享文件、URL Scheme、冷启动参数展示；
- Android `content://` 文件解析；
- iOS Universal Link / 打开文件；
- macOS Finder 打开文件；
- HarmonyOS `Want` / `SharedData` / URI 拷贝。

```bash
cd example
flutter run -d <device>
```

示例包名保持为 `fl.shared.link.example`，应用名为 `FlSharedLink`。

## 注意事项

1. **冷启动与热启动**：`receiveHandler` 只处理进程存活期间的打开事件；
   冷启动数据请通过 getter 读取一次，再注册监听。
2. **iOS UIScene**：Flutter 3.29+ 模板默认使用 `FlutterSceneDelegate`，插件已同时注册
   `UIApplicationDelegate` 与 `FlutterSceneLifeCycleDelegate`，两种生命周期均可工作。
3. **macOS Universal Link**：暂不支持，仅支持 URL Scheme 与 Finder 打开文件。
4. **文件拷贝**：iOS / macOS 拷贝到 `FileManager.temporaryDirectory`；
   Android 拷贝到应用外部缓存目录；HarmonyOS 拷贝到应用 `cacheDir`。
   系统可能随时清理临时文件，请及时转存到业务目录。
5. **Android 分享列表重复**：请参考上文使用 `SharedLauncherActivity`，不要在
   `MainActivity` 与 `SharedLauncherActivity` 中配置相同的 `intent-filter`。

## License

MIT License，详见 [LICENSE](LICENSE)。

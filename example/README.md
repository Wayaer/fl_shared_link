# fl_shared_link_example

`fl_shared_link` 的示例应用，演示 Android、iOS、macOS 与 HarmonyOS 四个平台的分享 / 打开事件接入。

## 运行

```bash
flutter pub get
flutter run -d <device>
```

应用名称为 `FlSharedLink`，各平台包名保持为 `fl.shared.link.example`。

## 功能演示

| 平台 | 演示内容 |
| --- | --- |
| Android | 分享 / 打开文件 Intent、`content://` 转真实路径 |
| iOS | URL Scheme、Universal Link、冷启动参数、文件拷贝 |
| macOS | URL Scheme、Finder 打开文件、文件拷贝 |
| HarmonyOS | `Want`、`NewWant`、`SharedData`、URI 拷贝 |

## 测试打开事件

- Android：

```bash
adb shell am start -a android.intent.action.VIEW \
  -d "flsharedlink://open?from=adb" fl.shared.link.example
```

- iOS 模拟器：

```bash
xcrun simctl openurl booted "flsharedlink://open?from=simulator"
```

- macOS：

```bash
open "flsharedlink://open?from=terminal"
```

- HarmonyOS：通过系统分享面板把文件分享到「FlSharedLink」。

## 平台配置

平台配置方式与插件 README 中的「平台配置」章节一致，示例工程已经完成对应配置，可直接作为接入参考。

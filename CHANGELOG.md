## 0.5.0

* 新增 macOS 平台支持
* iOS 与 macOS 共用 `darwin/fl_shared_link/Sources` 下的同一份原生实现（`sharedDarwinSource`）
* 新增 Swift Package Manager 支持（`darwin/fl_shared_link/Package.swift`）
* iOS 适配 Flutter 3.29+ 默认启用的 UIScene 生命周期（`FlutterSceneLifeCycleDelegate`）
* 修复 iOS `handleOpenURL` 场景下无法拷贝文件的问题
* `externalFileCopyWithIOS` 统一返回拷贝后的真实路径（不再返回 `file://` URL）
* 修复 `IOSAction.openURL` / `IOSAction.handleOpenURL` 与原生回调不一致的问题
* 新增 `IOSAction.openFile`，用于区分 macOS 通过 Finder 打开的文件
* 修复 `AndroidMineType.jva` 的 MIME 值拼写错误，并更名为 `AndroidMineType.jar`
* 最低 Flutter 版本调整为 3.41（依赖 `FlutterSceneLifeCycleDelegate`）
* 补充 README、API 注释与各平台配置说明
* 示例工程使用 Flutter 3.47 模板重建 Android、iOS、macOS、HarmonyOS 平台工程，并重构 UI
* Android 插件工程迁移到 Kotlin DSL 与新版 AGP 配置
* 补充 pub.dev 发布所需的 homepage、issue_tracker、topics 与隐私清单文件

## 0.4.3

* Add error log output

## 0.4.1

* Supports HarmonyOS

## 0.3.2

* Fix the issue where other plugins cannot obtain callback parameters on iOS

## 0.3.1

* Removed `removingPercentEncodingWithIOS`
* Added `externalFileCopyWithIOS`,IOS supports copying external files directly to the current
  sandbox temporary directory
* Added `clearCache`
* JDK changed to 17 on Android

## 0.3.0

* Update gradle version

## 0.2.0

* [Merged pull](https://github.com/Wayaer/fl_shared_link/pull/2#issue-2333998538)

## 0.1.1

* Add `namespace` in Android

## 0.1.0

* Add document

## 0.0.3

* Release version

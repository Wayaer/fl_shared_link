#if os(iOS)
import Flutter
import Photos
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#endif

/// Flutter 插件原生实现。
///
/// iOS 与 macOS 共用同一份源码：
/// - iOS：监听 `openURL` / `handleOpenURL` / `NSUserActivity`（Universal Link）；
/// - macOS：监听 `application(_:open:)`，同时覆盖自定义 URL Scheme 与 Finder 打开的文件。
public class FlSharedLinkPlugin: NSObject, FlutterPlugin {
    /// Universal Link 数据（仅 iOS）。
    private var universalLinkMap: [String: Any?] = [:]

    /// 最近一次 URL Scheme / 文件打开数据。
    private var openUrlMap: [String: Any?] = [:]

    /// iOS 冷启动参数。
    private var launchingWithOptionsMap: [AnyHashable: Any] = [:]

    /// 事件 id 与 URL 的映射，用于后续拷贝文件。
    private var uriMap: [String: URL] = [:]

    private var channel: FlutterMethodChannel

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger = registrar.messenger()
        #elseif os(macOS)
        let messenger = registrar.messenger
        #endif

        let channel = FlutterMethodChannel(name: "fl.shared.link", binaryMessenger: messenger)
        let instance = FlSharedLinkPlugin(channel)
        registrar.addApplicationDelegate(instance)
        #if os(iOS)
        // Flutter 3.29+ 的 iOS 模板默认启用 UIScene 生命周期，
        // 需要额外注册 SceneDelegate 才能收到 URL 与 Universal Link 回调。
        registrar.addSceneDelegate(instance)
        #endif
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getUniversalLinkMap":
            result(universalLinkMap)
        case "getOpenUrlMap":
            result(openUrlMap)
        case "externalFileCopy":
            guard let id = call.arguments as? String else {
                result(nil)
                return
            }
            externalFileCopy(id, result)
        case "getAbsolutePath":
            guard let identifier = call.arguments as? String else {
                result(nil)
                return
            }
            result(getAbsolutePath(identifier))
        case "getLaunchingOptionsMap":
            result(launchingOptionsMap())
        case "clearCache":
            universalLinkMap.removeAll()
            openUrlMap.removeAll()
            launchingWithOptionsMap.removeAll()
            uriMap.removeAll()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// 将外部文件拷贝到应用临时目录，返回拷贝后的绝对路径。
    ///
    /// 支持沙盒环境下的 security-scoped URL（iOS 文件选择器、macOS Finder 打开的文件）。
    private func externalFileCopy(_ id: String, _ result: @escaping FlutterResult) {
        guard let sourceUrl = uriMap[id] else {
            result(nil)
            return
        }

        let fileManager = FileManager.default
        let didStartAccessing = sourceUrl.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                sourceUrl.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let targetURL = fileManager.temporaryDirectory.appendingPathComponent(sourceUrl.lastPathComponent)
            if fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.removeItem(at: targetURL)
            }
            try fileManager.copyItem(at: sourceUrl, to: targetURL)
            result(targetURL.path)
        } catch {
            print("FlSharedLinkPlugin externalFileCopy error: \(error)")
            result(nil)
        }
    }

    /// iOS 冷启动参数转换为 `[String: String]`，便于通过 MethodChannel 传递。
    private func launchingOptionsMap() -> [String: String] {
        #if os(iOS)
        var map = [String: String]()
        launchingWithOptionsMap.forEach { (key: AnyHashable, value: Any) in
            map.updateValue(String(describing: value), forKey: String(describing: key))
        }
        return map
        #elseif os(macOS)
        // macOS 没有与 iOS `launchOptions` 对应的冷启动参数。
        return [:]
        #endif
    }

    /// 解析文件绝对路径。
    ///
    /// - iOS：支持文件 URL 与相册资源标识符（`PHAsset.localIdentifier`）；
    /// - macOS：支持文件 URL 与普通绝对路径。
    private func getAbsolutePath(_ identifier: String) -> String? {
        #if os(iOS)
        if identifier.starts(with: "file://") || identifier.starts(with: "/var/mobile/Media") ||
            identifier.starts(with: "/private/var/mobile") {
            return URL(string: identifier)?.path ?? identifier.replacingOccurrences(of: "file://", with: "")
        }
        let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: .none).firstObject
        if phAsset == nil {
            return nil
        }
        let (url, _) = getFullSizeImageURLAndOrientation(phAsset!)
        return url
        #elseif os(macOS)
        if identifier.starts(with: "file://") {
            return URL(string: identifier)?.path
        }
        return identifier.starts(with: "/") ? identifier : nil
        #endif
    }

    #if os(iOS)
    private func getFullSizeImageURLAndOrientation(_ asset: PHAsset) -> (String?, Int) {
        var url: String?
        var orientation: Int = 0
        let semaphore = DispatchSemaphore(value: 0)
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options) { input, _ in
            orientation = Int(input?.fullSizeImageOrientation ?? 0)
            url = input?.fullSizeImageURL?.path
            semaphore.signal()
        }
        semaphore.wait()
        return (url, orientation)
    }
    #endif

    #if os(iOS)
    // MARK: - UIApplicationDelegate

    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        recordUniversalLink(userActivity)
        channel.invokeMethod("onUniversalLink", arguments: universalLinkMap)
        return false
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        var extras = [String: Any]()
        options.forEach { key, value in
            extras[key.rawValue] = value
        }
        recordOpenUrl(url, action: "openURL", extras: extras)
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return false
    }

    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        recordOpenUrl(url, action: "handleOpenURL")
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return false
    }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
    ) -> Bool {
        launchingWithOptionsMap = launchOptions
        return false
    }

    private func recordUniversalLink(_ userActivity: NSUserActivity) {
        let id = String(describing: userActivity.webpageURL?.hashValue ?? 0)
        if let webpageURL = userActivity.webpageURL {
            uriMap[id] = webpageURL
        }
        universalLinkMap = [
            "id": id,
            "url": userActivity.webpageURL?.absoluteString,
            "scheme": userActivity.webpageURL?.scheme,
            "action": userActivity.activityType,
            "userInfo": userActivity.userInfo,
            "title": userActivity.title,
        ]
    }

    private func recordOpenUrl(_ url: URL, action: String, extras: [String: Any]? = nil) {
        let id = String(describing: url.hashValue)
        uriMap[id] = url
        var map: [String: Any?] = [
            "id": id,
            "url": url.absoluteString,
            "scheme": url.scheme,
            "action": action,
        ]
        if let extras {
            map["extras"] = extras
        }
        openUrlMap = map
    }
    #elseif os(macOS)
    // MARK: - NSApplicationDelegate

    /// 处理 macOS 的打开事件（自定义 URL Scheme 或 Finder 打开的文件）。
    ///
    /// 返回 `true` 表示事件已被插件消费，避免继续传递给其它 delegate。
    public func handleOpen(_ urls: [URL]) -> Bool {
        guard let url = urls.last else {
            return false
        }

        for openedUrl in urls {
            let id = String(describing: openedUrl.hashValue)
            uriMap[id] = openedUrl
            openUrlMap = [
                "id": id,
                "url": openedUrl.absoluteString,
                "scheme": openedUrl.scheme,
                "action": openedUrl.isFileURL ? "openFile" : "openURL",
            ]
            channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        }
        return url.isFileURL || url.scheme != nil
    }
    #endif
}

#if os(iOS)
// MARK: - UIScene 生命周期

/// Flutter 3.29+ 的 iOS 工程默认启用 UIScene，URL 与 Universal Link
/// 会通过 SceneDelegate 回调；这里统一转发给插件。
extension FlSharedLinkPlugin: FlutterSceneLifeCycleDelegate {
    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        guard let connectionOptions else {
            return false
        }
        if let context = connectionOptions.urlContexts.first {
            var extras: [String: Any] = [
                "openInPlace": context.options.openInPlace,
            ]
            if let sourceApplication = connectionOptions.sourceApplication {
                extras["sourceApplication"] = sourceApplication
            }
            recordOpenUrl(context.url, action: "openURL", extras: extras)
            channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        }
        if let userActivity = connectionOptions.userActivities.first(where: {
            $0.activityType == NSUserActivityTypeBrowsingWeb
        }) {
            recordUniversalLink(userActivity)
            channel.invokeMethod("onUniversalLink", arguments: universalLinkMap)
        }
        // 不独占连接事件，避免影响其它插件。
        return false
    }

    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        guard let context = URLContexts.first else {
            return false
        }
        let extras: [String: Any] = [
            "openInPlace": context.options.openInPlace,
        ]
        recordOpenUrl(context.url, action: "openURL", extras: extras)
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return true
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        recordUniversalLink(userActivity)
        channel.invokeMethod("onUniversalLink", arguments: universalLinkMap)
        return true
    }
}
#endif


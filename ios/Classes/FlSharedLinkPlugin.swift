import Flutter
import Photos
import UIKit

public class FlSharedLinkPlugin: NSObject, FlutterPlugin {
    private var universalLinkMap: [AnyHashable: Any?]?
    private var openUrlMap: [AnyHashable: Any?]?
    private var launchingWithOptionsMap: [AnyHashable: Any]?
    private var channel: FlutterMethodChannel

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl.shared.link", binaryMessenger: registrar.messenger())
        let instance = FlSharedLinkPlugin(channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getUniversalLinkMap":
            result(universalLinkMap)
        case "getOpenUrlMap":
            result(openUrlMap)
        case "removingPercentEncoding":
            result((call.arguments as! String).removingPercentEncoding)
        case "getAbsolutePath":
            result(getAbsolutePath(call.arguments as! String))
        case "getLaunchingOptionsMap":
            var map = [String: String]()
            launchingWithOptionsMap?.forEach({ (key: AnyHashable, value: Any) in
                map.updateValue(String(describing: value), forKey: String(describing: key))
            })
            result(map)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        universalLinkMap = [
            "url": userActivity.webpageURL?.absoluteString,
            "scheme": userActivity.webpageURL?.scheme,
            "action": userActivity.activityType,
            "userInfo": userActivity.userInfo,
            "title": userActivity.title,
        ]
        channel.invokeMethod("onUniversalLink", arguments: universalLinkMap)
        return false
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        openUrlMap = [
            "url": url.absoluteString,
            "scheme": url.scheme,
            "action": "openUrl",
            "extras": options,
        ]
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return false
    }

    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        openUrlMap = [
            "url": url.absoluteString,
            "scheme": url.scheme,
            "action": "handleOpenUrl",
        ]
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return false
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        launchingWithOptionsMap = launchOptions
        return false
    }

    private func getAbsolutePath(_ identifier: String) -> String? {
        if (identifier.starts(with: "file://") || identifier.starts(with: "/var/mobile/Media") || identifier.starts(with: "/private/var/mobile")) {
            return identifier.replacingOccurrences(of: "file://", with: "")
        }
        let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: .none).firstObject
        if (phAsset == nil) {
            return nil
        }
        let (url, _) = getFullSizeImageURLAndOrientation(phAsset!)
        return url
    }

    private func getFullSizeImageURLAndOrientation(_ asset: PHAsset) -> (String?, Int) {
        var url: String? = nil
        var orientation: Int = 0
        let semaphore = DispatchSemaphore(value: 0)
        let options2 = PHContentEditingInputRequestOptions()
        options2.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options2) { (input, info) in
            orientation = Int(input?.fullSizeImageOrientation ?? 0)
            url = input?.fullSizeImageURL?.path
            semaphore.signal()
        }
        semaphore.wait()
        return (url, orientation)
    }
}

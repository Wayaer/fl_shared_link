import Flutter
import UIKit

public class FlBeSharedPlugin: NSObject, FlutterPlugin {
    private var universalLinkMap: [AnyHashable: Any?]?
    private var openUrlMap: [AnyHashable: Any?]?

    private var channel: FlutterMethodChannel


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_be_shared", binaryMessenger: registrar.messenger())
        let instance = FlBeSharedPlugin(channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getUniversalLinkMap":
            result(universalLinkMap)
        case "getOpenUrlMap":
            result(openUrlMap)
        default:
            result(FlutterMethodNotImplemented)
        }
    }


    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        universalLinkMap = [
            "url": userActivity.webpageURL?.absoluteString,
            "scheme": userActivity.webpageURL?.scheme,
            "type": userActivity.activityType,
            "userInfo": userActivity.userInfo,
            "title": userActivity.title,
        ]
        channel.invokeMethod("onUniversalLink", arguments: universalLinkMap)
        return true
    }


    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        openUrlMap = [
            "url": url.absoluteString,
            "scheme": url.scheme,
            "type": "openUrl",
            "extras": options,
        ]
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return true
    }

    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        openUrlMap = [
            "url": url.absoluteString,
            "scheme": url.scheme,
            "type": "handleOpenUrl",
        ]
        channel.invokeMethod("onOpenUrl", arguments: openUrlMap)
        return true
    }

}

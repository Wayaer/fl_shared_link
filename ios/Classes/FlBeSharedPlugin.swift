import Flutter
import UIKit

public class FlBeSharedPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fl_be_shared", binaryMessenger: registrar.messenger())
    let instance = FlBeSharedPlugin()
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

  }
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        print("userActivity")
        print(userActivity.activityType)
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        print("openUrl sourceApplication")
        print(url)
        print(sourceApplication)
        print(annotation)
        return true
    }
    
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("openUrl options")
        print(url)
        print(options)
        return true
    }
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("handleOpen url")
        print(url)
        return true
    }
}

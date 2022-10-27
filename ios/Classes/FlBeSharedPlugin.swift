import Flutter
import UIKit

public class FlBeSharedPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "fl_be_shared", binaryMessenger: registrar.messenger())
    let instance = FlBeSharedPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

  }
}

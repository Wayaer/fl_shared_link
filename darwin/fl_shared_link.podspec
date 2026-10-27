#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fl_shared_link.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fl_shared_link'
  s.version          = '0.5.0'
  s.summary          = 'Receive links, files and share intents when the Flutter app is opened.'
  s.description      = <<-DESC
A Flutter plugin that receives Android Intents, iOS/macOS URLs and opened files, and HarmonyOS Want/SharedData when the app is opened or shared to.
                       DESC
  s.homepage         = 'https://github.com/Wayaer/fl_shared_link'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wayaer' => 'https://github.com/Wayaer' }
  s.source           = { :path => '.' }
  s.source_files     = 'fl_shared_link/Sources/fl_shared_link/**/*'

  # 同时支持 iOS 与 macOS，原生源码统一放在 fl_shared_link/Sources 下。
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  # 按平台声明对应的 Flutter 引擎依赖。
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  # iOS 使用 Photos 解析相册资源标识符。
  s.ios.frameworks = 'Photos'

  # Flutter.framework does not contain a i386 slice.
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  # Privacy manifest（App Store 隐私清单）。
  s.resource_bundles = { 'fl_shared_link_privacy' => ['fl_shared_link/Sources/fl_shared_link/PrivacyInfo.xcprivacy'] }
end

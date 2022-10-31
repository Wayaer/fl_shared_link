# fl_shared_link

Android 配置 (project/android/app/src/main/AndroidManifest.xml)

```xml
<!-- 注册接收分享 -->
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <!--接收打开的文件类型-->
    <data android:mimeType="application/pdf" />
</intent-filter>

```

```xml
<!-- 注册默认打开事件，微信、QQ的其他应用打开 -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />

    <data android:scheme="file" />
    <data android:scheme="content" />

    <!-- 接收打开的文件类型 -->
    <data android:mimeType="application/pdf" />
</intent-filter>
```

```xml
<!-- mimeType 部分可接收的类型 -->
<intent-filter>
    <data android:mimeType="image/*" />
    <data android:mimeType="text/*" />
    <data android:mimeType="application/msword" />
    <data
        android:mimeType="application/vnd.openxmlformats-officedocument.wordprocessingml.document" />
    <data android:mimeType="application/vnd.ms-excel" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
    <data android:mimeType="application/vnd.ms-powerpoint" />
    <data
        android:mimeType="application/vnd.openxmlformats-officedocument.presentationml.presentation" />
    <data android:mimeType="application/pdf" />
</intent-filter>
```

- 使用（Android）

```dart
void func() async {
  /// 获取 android 所有 Intent
  final intent = await FlSharedLink().intentWithAndroid;

  /// 当前获取到intent中的uri中带有文件路径，会自动转换为 文件真实路径 微信或qq等部分app内部文件无法获取
  final realPath = await FlSharedLink().getRealFilePathWithAndroid();

  /// 当前获取到intent中的uri中带有文件路径，会自动转换为 文件真实路径 兼容微信或qq
  /// 此方法会拷贝文件至当前app内部空间
  final realPath = await FlSharedLink().getRealFilePathCompatibleWXQQWithAndroid();

  FlSharedLink().receiveHandler(onIntent: (AndroidIntentModel? data) {
    /// 监听 android 所有的 intent 数据
    /// 被分享或被打开 携带的参数 都在这里获取
  });
}


```

IOS 配置 (project/ios/Runner/Info.plist)
[LSItemContentTypes详细](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)

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
```

- 使用（IOS）

```dart
void func() async {
  /// 通过universalLink启动app获取上一次启动携带的参数
  /// 通常 微信分享qq分享返回app中 
  final universalLink = await FlSharedLink().universalLinkWithIOS;

  /// 通过openUrl或handleOpenUrl启动app获取上一个启动携带的参数
  /// 通常 用 其他应用打开 分享 或 打开 携带的参数从这里获取
  final openUrl = await FlSharedLink().openUrlWithIOS;

  FlSharedLink().receiveHandler(
      onUniversalLink: (IOSUniversalLinkModel? data) {
        /// 监听通过 universalLink 打开app 回调以及参数
      },
      onOpenUrl: (IOSOpenUrlModel? data) {
        /// 监听通过 openUrl或者handleOpenUrl 打开app 回调以及参数
      });
}
```
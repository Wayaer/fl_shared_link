# fl_shared_link

# Android configuration items

Android MainActivity `project/android/app/src/main/AndroidManifest.xml`

```xml

<activity android:name=".MainActivity">
    ...
    <!-- 注册接收分享 -->
    <!-- Sign up to share -->
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <!--接收分享的文件类型-->
        <!--Type of file to be shared-->
        <data android:mimeType="application/pdf" />
    </intent-filter>
    <!-- 注册默认打开事件，微信、QQ的其他应用打开 -->
    <!-- Register the default open event, other applications open -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />

        <data android:scheme="file" />
        <data android:scheme="content" />

        <!-- 接收打开的文件类型 -->
        <!-- Receive open file types -->
        <data android:mimeType="application/pdf" />
    </intent-filter>
    ...
</activity>
```

```xml
<!-- mimeType 部分可接收的类型 -->
<!-- mimeType -->
<intent-filter>
    <data android:mimeType="image/*" />
    <data android:mimeType="text/*" />
    <data android:mimeType="application/msword" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.wordprocessingml.document" />
    <data android:mimeType="application/vnd.ms-excel" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
    <data android:mimeType="application/vnd.ms-powerpoint" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.presentationml.presentation" />
    <data android:mimeType="application/pdf" />
</intent-filter>
```

- Use（Android）

```dart
void func() async {
  /// 获取 android 所有 Intent
  /// Get the Intent for android
  final intent = await FlSharedLink().intentWithAndroid;

  /// 当前获取到intent中的uri中带有文件路径，会自动转换为 文件真实路径 兼容微信或qq
  /// 微信或QQ 此方法会拷贝文件至当前app内部空间
  /// The uri currently obtained into the intent contains a file path, which is automatically converted to the true path of the file
  final realPath = await FlSharedLink().getRealFilePathWithAndroid(intent.id);

  FlSharedLink().receiveHandler(onIntent: (AndroidIntentModel? data) {
    /// 监听 android 所有的 intent 数据
    /// Listen to all android intent data
    /// 被分享或被打开 携带的参数 都在这里获取
    /// Parameters that are shared or opened and carried are obtained here
  });
}


```

### 为解决 telegram和email等其他app，在分享到自己的app时，自己的app覆盖了原本的app，而不是跳转到自己的app，解决办法如下

### In order to solve other apps such as telegram and email, when sharing your app, your app overwrites the original app instead of jumping to your app, the solution is as follows

- 复制 `example/android/app/src/main/kotlin/fl/shared/link/example/SharedLauncherActivity.kt` 文件到你自己app的目录下，与 `MainActivity`在同一个目录
- Copy `example/android/app/src/main/kotlin/fl/Shared/link/example/SharedLauncherActivity.kt ` file to the directory of your own app, In the same directory as MainActivity
- 添加以下配置到 `project/android/app/src/main/AndroidManifest.xml`
- Add the following configuration to  `project/android/app/src/main/AndroidManifest.xml`

* 请移除 `MainActivity` 中的相同的 `intent-filter` 配置，避免在分享列表里出现两个自己的app
* Please remove the same intent-filter configuration in MainActivity to avoid having two of your own apps in the share list

```xml

<activity android:exported="true" android:hardwareAccelerated="true" android:launchMode="singleInstance" android:name=".SharedLauncherActivity" android:theme="@style/LaunchTheme">

    <!-- 注册接收分享 -->
    <!-- Sign up to share -->
    <intent-filter android:label="SharedLauncher接收">
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <!--接收分享的文件类型-->
        <!--Type of file to be shared-->
        <data android:mimeType="*/*" />
    </intent-filter>

    <!-- 注册默认打开事件，微信、QQ的其他应用打开 -->
    <!-- Register the default open event, other applications open -->
    <intent-filter android:label="SharedLauncher打开">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />

        <data android:scheme="file" />
        <data android:scheme="content" />
        <!-- 接收打开的文件类型 -->
        <!-- Receive open file types -->
        <data android:mimeType="*/*" />
    </intent-filter>
</activity>

```

> [!NOTE] 
> Opening files from different explorers and sources currently launches a new instance of the app each time. To avoid this behavior and ensure the app runs as a single instance, update the `android:launchMode` attribute in the activity tag of your `AndroidManifest.xml` file to `android:launchMode="singleInstancePerTask"`.  The file is located at `android/app/src/main/AndroidManifest.xml`.

# IOS configuration items

IOS `project/ios/Runner/Info.plist`
[LSItemContentTypes](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)

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

- Use（IOS）

```dart
void func() async {
  /// 通过universalLink启动app获取上一次启动携带的参数
  /// 通常 微信分享qq分享返回app中 
  /// The universalLink startup app gets the parameters carried by the last startup
  final universalLink = await FlSharedLink().universalLinkWithIOS;

  /// 通过openUrl或handleOpenUrl启动app获取上一个启动携带的参数
  /// The openUrl or handleOpenUrl startup app gets the parameters carried by the last startup
  /// 通常 用 其他应用打开 分享 或 打开 携带的参数从这里获取
  /// Usually open share with other applications or open carry parameters obtained from here
  final openUrl = await FlSharedLink().openUrlWithIOS;

  /// app首次启动 获取启动参数
  /// When the app starts for the first time, the startup parameters are obtained
  final Map? launchingOptionsWithIOS = await FlSharedLink().launchingOptionsWithIOS;

  FlSharedLink().receiveHandler(
      onUniversalLink: (IOSUniversalLinkModel? data) {
        /// 监听通过 universalLink 打开app 回调以及参数
        /// Listen to open app callbacks and parameters through universalLink
      },
      onOpenUrl: (IOSOpenUrlModel? data) {
        /// 监听通过 openUrl或者handleOpenUrl 打开app 回调以及参数
        /// Listen to open app callbacks and parameters via openUrl or handleOpenUrl
      });
}
```

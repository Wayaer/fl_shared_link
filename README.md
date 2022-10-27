# fl_be_shared

Android 配置

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
<!-- mimeType 可接收的类型 -->
<intent-filter>
    <data android:mimeType="image/*" />
    <data android:mimeType="application/msword" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.wordprocessingml.document" />
    <data android:mimeType="application/vnd.ms-excel" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" />
    <data android:mimeType="application/vnd.ms-powerpoint" />
    <data android:mimeType="application/vnd.openxmlformats-officedocument.presentationml.presentation" />
    <data android:mimeType="application/pdf" />
    <data android:mimeType="text/plain" />
</intent-filter>
```
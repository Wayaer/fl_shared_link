# fl_be_shared

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
<!-- mimeType 可接收的类型 -->
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
IOS 配置 (project/ios/Runner/Info.plist)
```xml
<key>CFBundleDocumentTypes</key>
<array>
<dict>
    <key>CFBundleTypeName</key>
    <string>FlBeShared</string>
    <key>LSHandlerRank</key>
    <string>Default</string>
    <key>LSItemContentTypes</key>
    <array>
        <string>public.data</string>
        <string>public.word</string>
    </array>
</dict>
</array>

<key>UTExportedTypeDeclarations</key><array>
<dict>
    <key>UTTypeConformsTo</key>
    <array>
        <string>public.data</string>
        <string>public.composite-content</string>
    </array>
    <key>UTTypeDescription</key>
    <string>PDF文档</string>
    <key>UTTypeIdentifier</key>
    <string>com.adobe.pdf</string>
    <key>UTTypeTagSpecification</key>
    <dict>
        <key>public.filename-extension</key>
        <array>
            <string>pdf</string>
        </array>
        <key>public.mime-type</key>
        <string>application/pdf</string>
    </dict>
</dict>
<dict>
    <key>UTTypeConformsTo</key>
    <array>
        <string>public.data</string>
    </array>
    <key>UTTypeDescription</key>
    <string>Word文档</string>
    <key>UTTypeIdentifier</key>
    <string>com.microsoft.word.doc</string>
    <key>UTTypeTagSpecification</key>
    <dict>
        <key>public.filename-extension</key>
        <array>
            <string>doc</string>
            <string>docx</string>
        </array>
        <key>public.mime-type</key>
        <string>application/msword</string>
    </dict>
</dict>
<dict>
    <key>UTTypeConformsTo</key>
    <array>
        <string>public.data</string>
    </array>
    <key>UTTypeDescription</key>
    <string>Excel Document</string>
    <key>UTTypeIdentifier</key>
    <string>com.microsoft.excel.xls</string>
    <key>UTTypeTagSpecification</key>
    <dict>
        <key>public.filename-extension</key>
        <array>
            <string>xls</string>
        </array>
        <key>public.mime-type</key>
        <string>application/vnd.ms-excel</string>
    </dict>
</dict>
</array>
```
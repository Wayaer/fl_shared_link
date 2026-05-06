import 'package:fl_shared_link/fl_shared_link.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

bool get _isHarmonyOS => defaultTargetPlatform.name == 'ohos';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: const Text('FlSharedLink Plugin')),
          body: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const SingleChildScrollView(child: HomePage())))));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// ios
  IOSUniversalLinkModel? universalLink;
  Map? launchingOptionsWithIOS;
  IOSOpenUrlModel? openUrl;

  /// harmonyos
  HarmonyOSNewWantModel? newWantModel;
  HarmonyOSWantModel? wantModel;
  List<HarmonyOSSharedRecordModel>? sharedData;
  String? newPath;

  /// android
  AndroidIntentModel? intent;
  String? realPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FlSharedLink().receiveHandler(
          onUniversalLink: (IOSUniversalLinkModel data) {
        universalLink = data;
        setState(() {});
      }, onOpenUrl: (IOSOpenUrlModel data) {
        openUrl = data;
        setState(() {});
      }, onIntent: (AndroidIntentModel data) {
        intent = data;
        setState(() {});
      }, onWant: (HarmonyOSNewWantModel data) async {
        newWantModel = data;
        sharedData = await FlSharedLink().wantSharedDataWithHarmonyOS;
        setState(() {});
      });
      if (_isIOS) {
        universalLink = await FlSharedLink().universalLinkWithIOS;
        openUrl = await FlSharedLink().openUrlWithIOS;
        launchingOptionsWithIOS = await FlSharedLink().launchingOptionsWithIOS;
      }
      if (_isAndroid) intent = await FlSharedLink().intentWithAndroid;
      if (_isHarmonyOS) {
        wantModel = await FlSharedLink().wantWithHarmonyOS;
        sharedData = await FlSharedLink().wantSharedDataWithHarmonyOS;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (_isAndroid) children = androidChildren;
    if (_isIOS) children = iosChildren;
    if (_isHarmonyOS) children = harmonyOSChildren;
    return Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...children,
          ElevatedButton(
              onPressed: FlSharedLink().clearCache, child: const Text('清除缓存'))
        ]);
  }

  List<Widget> get harmonyOSChildren => [
        const Text('HarmonyOS Want'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text('${wantModel?.toMap()}', textAlign: TextAlign.start)),
        const Text('HarmonyOS NewWant'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child:
                Text('${newWantModel?.toMap()}', textAlign: TextAlign.start)),
        const Text('HarmonyOS SharedData'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text(
                '${sharedData?.map((e) => e.toMap()).toList().join('\n')}',
                textAlign: TextAlign.start)),
        ElevatedButton(
            onPressed: uriCopyToCachePathWithHarmonyOS,
            child: const Text('HarmonyOS uri转本地路径')),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text('$newPath', textAlign: TextAlign.start)),
      ];

  void uriCopyToCachePathWithHarmonyOS() async {
    final data = sharedData?.firstOrNull;
    if (data != null) {
      newPath =
          await FlSharedLink().uriCopyToCachePathWithHarmonyOS(data.uri ?? '');
      setState(() {});
    }
  }

  List<Widget> get androidChildren => [
        const Text('Android Intent'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text('${intent?.toMap()}', textAlign: TextAlign.start)),
        ElevatedButton(
            onPressed: getRealFilePathWithAndroid,
            child: const Text('Android uri转真实文件地址 兼容微信QQ')),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text('$realPath', textAlign: TextAlign.start)),
      ];

  void getRealFilePathWithAndroid() async {
    final id = intent?.id;
    if (id == null) return;
    realPath = await FlSharedLink().getRealFilePathWithAndroid(id);
    setState(() {});
  }

  List<Widget> get iosChildren => [
        const Text('IOS Launching Options'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child:
                Text('$launchingOptionsWithIOS', textAlign: TextAlign.start)),
        const Text('IOS UniversalLink'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child:
                Text('${universalLink?.toMap()}', textAlign: TextAlign.start)),
        const Text('IOS openUrl'),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withValues(alpha: 0.3)),
            child: Text('${openUrl?.toMap()}', textAlign: TextAlign.start)),
      ];
}

import 'package:fl_shared_link/fl_shared_link.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("==== dart start dart main");
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
  IOSUniversalLinkModel? universalLink;
  IOSOpenUrlModel? openUrl;
  Map? launchingOptionsWithIOS;
  AndroidIntentModel? intent;
  ValueNotifier<String?> realPath = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isIOS) {
        universalLink = await FlSharedLink().universalLinkWithIOS;
        openUrl = await FlSharedLink().openUrlWithIOS;
        launchingOptionsWithIOS = await FlSharedLink().launchingOptionsWithIOS;
      }
      if (_isAndroid) intent = await FlSharedLink().intentWithAndroid;
      setState(() {});
      FlSharedLink().receiveHandler(
          onUniversalLink: (IOSUniversalLinkModel? data) {
        universalLink = data;
        setState(() {});
      }, onOpenUrl: (IOSOpenUrlModel? data) {
        openUrl = data;
        setState(() {});
      }, onIntent: (AndroidIntentModel? data) {
        intent = data;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (_isAndroid) children = androidChildren;
    if (_isIOS) children = iosChildren;
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children);
  }

  List<Widget> get androidChildren => [
        const Text('Android Intent'),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.3)),
            child: Text('${intent?.toMap()}')),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: getRealFilePathWithAndroid,
            child: const Text('Android uri转真实文件地址 兼容微信QQ')),
        const SizedBox(height: 10),
        ValueListenableBuilder(
            valueListenable: realPath,
            builder: (_, String? value, __) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.withOpacity(0.3)),
                child: Text(value.toString()))),
        const SizedBox(height: 30),
      ];

  void getRealFilePathWithAndroid() async {
    final id = intent?.id;
    if (id == null) return;
    realPath.value = await FlSharedLink().getRealFilePathWithAndroid(id);
  }

  @override
  void dispose() {
    super.dispose();
    realPath.dispose();
  }

  List<Widget> get iosChildren => [
        const Text('IOS Launching Options'),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.3)),
            child: Text('$launchingOptionsWithIOS')),
        const SizedBox(height: 10),
        const Text('IOS UniversalLink'),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.3)),
            child: Text('${universalLink?.toMap()}')),
        const SizedBox(height: 10),
        const Text('IOS openUrl'),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.3)),
            child: Text('${openUrl?.toMap()}')),
        const SizedBox(height: 30),
      ];
}

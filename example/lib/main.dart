import 'package:fl_be_shared/fl_be_shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Widget child = const SizedBox();
  if (_isAndroid) child = const AndroidPage();
  if (_isIOS) child = const IOSPage();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: const Text('FlBeShared Plugin')),
          body: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(child: child)))));
}

class IOSPage extends StatefulWidget {
  const IOSPage({Key? key}) : super(key: key);

  @override
  State<IOSPage> createState() => _IOSPageState();
}

class _IOSPageState extends State<IOSPage> {
  IOSUniversalLinkModel? universalLink;
  IOSOpenUrlModel? openUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      universalLink = await FlBeShared().universalLinkWithIOS;
      openUrl = await FlBeShared().openUrlWithIOS;
      setState(() {});
      FlBeShared().receiveHandler(
          onUniversalLink: (IOSUniversalLinkModel? data) {
        universalLink = data;
        setState(() {});
      }, onOpenUrl: (IOSOpenUrlModel? data) {
        openUrl = data;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
        ]);
  }
}

class AndroidPage extends StatefulWidget {
  const AndroidPage({Key? key}) : super(key: key);

  @override
  State<AndroidPage> createState() => _AndroidPageState();
}

class _AndroidPageState extends State<AndroidPage> {
  AndroidIntentModel? intent;
  AndroidIntentModel? receiveShared;

  ValueNotifier<String?> realPath = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      receiveShared = await FlBeShared().receiveSharedWithAndroid;
      intent = await FlBeShared().intentWithAndroid;
      setState(() {});
      FlBeShared().receiveHandler(onReceiveShared: (AndroidIntentModel? data) {
        receiveShared = data;
        setState(() {});
      }, onIntent: (AndroidIntentModel? data) {
        intent = data;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          const Text('接收的分享数据'),
          const SizedBox(height: 10),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.withOpacity(0.3)),
              child: Text('${receiveShared?.toMap()}')),
          ElevatedButton(
              onPressed: getRealFilePathWithAndroid,
              child: const Text('Android uri转真实文件地址')),
          ElevatedButton(
              onPressed: getRealFilePathCompatibleWXQQWithAndroid,
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
        ]);
  }

  void getRealFilePathWithAndroid() async {
    realPath.value = await FlBeShared().getRealFilePathWithAndroid();
  }

  void getRealFilePathCompatibleWXQQWithAndroid() async {
    realPath.value =
        await FlBeShared().getRealFilePathCompatibleWXQQWithAndroid();
  }

  @override
  void dispose() {
    super.dispose();
    realPath.dispose();
  }
}

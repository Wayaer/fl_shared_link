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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AndroidPage extends StatefulWidget {
  const AndroidPage({Key? key}) : super(key: key);

  @override
  State<AndroidPage> createState() => _HomePageState();
}

class _HomePageState extends State<AndroidPage> {
  AndroidReceiveDataModel? androidIntent;
  AndroidReceiveDataModel? receiveShared;

  ValueNotifier<String?> realPath = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      receiveShared = await FlBeShared().receiveSharedWithAndroid;
      androidIntent = await FlBeShared().intentWithAndroid;
      setState(() {});
      FlBeShared().receiveHandler(
          onReceiveShared: (AndroidReceiveDataModel? data) {
        receiveShared = data;
        setState(() {});
      }, onAndroidIntent: (AndroidReceiveDataModel? data) {
        androidIntent = data;
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
              child: Text('${androidIntent?.toMap()}')),
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
}

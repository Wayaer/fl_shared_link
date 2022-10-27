import 'package:fl_be_shared/fl_be_shared.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: const Text('FlBeShared Plugin')),
          body: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: const SingleChildScrollView(child: HomePage())))));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AndroidIntent? androidIntent;
  AndroidIntent? receiveShared;

  ValueNotifier<String?> realPath = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      receiveShared = await FlBeShared().receiveData;
      androidIntent = await FlBeShared().androidIntent;
      setState(() {});
      FlBeShared().receiveHandler(onReceiveShared: (AndroidIntent? data) {
        receiveShared = data;
        setState(() {});
      }, onAndroidIntent: (AndroidIntent? data) {
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

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
              child: const HomePage()))));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ReceiveData? receiveData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      receiveData = await FlBeShared().receiveData;
      setState(() {});
      FlBeShared().receiveHandler(receiveData: (ReceiveData? data) {
        receiveData = data;
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
          const Text('接收的数据'),
          const SizedBox(height: 10),
          Text('data:\n ${receiveData?.data}'),
          const SizedBox(height: 10),
          Text('action: ${receiveData?.action}'),
        ]);
  }
}

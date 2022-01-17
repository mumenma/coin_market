import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  String text = "";
  final WebSocketChannel channel =
      IOWebSocketChannel.connect('wss://api.huobi.ws/ws');
  late StreamBuilder streamBuilder;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map map = {"sub": "market.btcusdt.ticker"};
    channel.sink.add(jsonEncode(map));

    channel.stream.listen((message) {
      List<int> decodeUint8List = gzip.decode(message);
      String str = String.fromCharCodes(decodeUint8List);
      Map map = jsonDecode(str);
      if (map.containsKey("ping")) {
        var time = map["ping"];
        Map map1 = {"pong": time};
        channel.sink.add(jsonEncode(map1));
      } else {
        Map tick = map["tick"];
        var close = tick["close"];
        setState(() {
          text = close.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.red, fontWeight: FontWeight.w700, fontSize: 100),
        ),
      ),
    );
  }
}

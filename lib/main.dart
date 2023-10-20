import 'package:fktv/qrcode.dart';
import 'package:fktv/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'fktv',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var playing = false;
  late AppHttpServer _server;
  var controller = VideoPlayerController.networkUrl(Uri.parse(
      'https://cdn.aor.games/common/astra-web/videos/AOR-trailer.mp4'));
  @override
  void initState() {
    super.initState();
    _server = AppHttpServer();
    _server.start();
    controller.addListener(() {
      print('init');
    });

    controller.initialize();
  }

  void play() {
    if (playing) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {
      playing = !playing;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    _server.stop();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: []);
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            VideoPlayer(controller),
             MyTopBar(
              title: _server.ip,
            ),
            TextButton(
                onPressed: play, child: Text(playing ? 'pause' : 'play')),
            ScanQrcode()
          ],
        ));
  }
}

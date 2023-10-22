import 'package:fktv/qrcode.dart';
import 'package:fktv/top_bar.dart';
import 'package:fktv/utils/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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
  Music? music;
  String serverIp = '127.0.0.1';
  String playerError = '';
  var playing = false;
  late AppHttpServer _server;
  var controller = VideoPlayerController.asset('');
  @override
  void initState() {
    super.initState();
    _server = AppHttpServer();
    _server.onMusicChane = onMusicChange;
    _server.start().then((value) => setIp());
  }

  void setIp() {
    setState(() {
      serverIp = _server.ip;
    });
  }

  void onMusicChange(Music? m) {
    print('切歌---->');
    setState(() {
      music = m;
      if (m != null) {
        controller.removeListener(() {});
        controller.dispose();
        controller = _server.createPlayer(m.url);
        controller.addListener(() {
          setState(() {});
        });
        initPlayer();
      }
    });
  }

  void initPlayer() async {
    try {
      await controller.initialize();
      controller.play();
      playerError = '';
    } catch (e) {
      music = null;
      playerError = '歌曲加载失败,请检查网络！';
      print('播放错误');
    }
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    String playerTitle = playerError.isEmpty
        ? (music == null ? '扫左下方二维码点歌' : ('正在播放：${music!.name}'))
        : playerError;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            VideoPlayer(controller),
            music == null
                ? (const Text(''))
                : VideoProgressIndicator(
                    controller,
                    allowScrubbing: false,
                    padding: const EdgeInsets.only(top: 0),
                  ),
            MyTopBar(
              title: playerTitle,
            ),
            TextButton(
                onPressed: play, child: Text(playing ? 'pause' : 'play')),
            const ScanQrcode()
          ],
        ));
  }
}

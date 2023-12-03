import 'package:fktv/player.dart';
import 'package:fktv/qrcode.dart';
import 'package:fktv/top_bar.dart';
import 'package:fktv/utils/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'server.dart';
import 'utils/events.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'fktv',
      home: MyHomePage(title: 'FKTV'),
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
  bool busying = false;
  MyEvents serverEvents = MyEvents();
  late AppHttpServer _server;
  var playerController = MediaPlayerController();
  @override
  void initState() {
    super.initState();
    serverEvents.on(MyEventsEnum.setMute, setMute);
    serverEvents.on(MyEventsEnum.setPlayerState, setPlayerState);
    _server = AppHttpServer(serverEvents);

    _server.onMusicChane = onMusicChange;
    _server.start().then((value) => setIp());
    startApiServer();
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
    });
    if (m != null) {
      playerController.setMedia(m);
    }
  }

  void setMute(double val) {
    playerController.setVolume(val);
  }

  void setPlayerState(bool? sta) {
    playerController.setPlayerState();
  }

  @override
  void dispose() {
    super.dispose();
    playerController.dispose();
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
            MediaPlayer(playerController),
            MyTopBar(
              title: playerTitle,
            ),
            const ScanQrcode(),
          ],
        ));
  }
}

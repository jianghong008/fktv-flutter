import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'commponents/lyrcs_reader.dart';
import 'utils/app_state.dart';
import 'utils/events.dart';
import 'utils/net_utils.dart';

class MediaPlayerController extends MyEvents {
  void setMedia(Music m) {
    emit(MyEventsEnum.setMedia, m);
  }

  void setVolume(double val) {
    emit(MyEventsEnum.setMute, val);
  }

  void setPlayerState() {
    emit(MyEventsEnum.setPlayerState, null);
  }

  void dispose() {}
}

class MediaPlayer extends StatefulWidget {
  final MediaPlayerController controller;
  const MediaPlayer(this.controller, {super.key});
  @override
  State<MediaPlayer> createState() => MediaPlayerState();
}

class MediaPlayerState extends State<MediaPlayer> {
  final lyrcController = LyrcsController();
  var videoPontroller = VideoPlayerController.asset('');
  final audioPlayer = AudioPlayer();
  double preccent = 0.0;
  int duration = 0;
  Music? music;
  bool isplaying = false;
  @override
  void initState() {
    super.initState();
    audioPlayer.onPositionChanged.listen((event) {
      onPositionChange(event.inMilliseconds);
    });

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.stopped) {
        isplaying = false;
        onMusicChange(AppState.musics.isNotEmpty ? AppState.next() : null);
      }
    });

    widget.controller.on(MyEventsEnum.setMedia, setMedia);
    widget.controller.on(MyEventsEnum.setMute, setMute);
    widget.controller.on(MyEventsEnum.setPlayerState, setPlayerState);
  }

  void setMute(double val) {
    if (music == null) {
      return;
    }
    if (music!.isVideo) {
      videoPontroller.setVolume(val);
    } else {
      audioPlayer.setVolume(val);
    }
  }

  void setPlayerState(bool? sta) {
    if (music == null) {
      return;
    }
    if (music!.isVideo) {
      if (isplaying) {
        videoPontroller.pause();
        isplaying = false;
      } else {
        videoPontroller.play();
        isplaying = true;
      }
    } else {
      if (isplaying) {
        audioPlayer.pause();
        isplaying = false;
      } else {
        audioPlayer.play(UrlSource(music!.url));
        isplaying = true;
      }
    }
  }

  void onMusicChange(Music? m) {
    if (m == null) {
      return;
    }
  }

  void createVideoPlayer(String url) async {
    try {
      videoPontroller.removeListener(onVideoChange);
      await videoPontroller.dispose();
      videoPontroller = VideoPlayerController.networkUrl(
          Uri.parse(httpsGenerate(url)),
          videoPlayerOptions:
              VideoPlayerOptions(allowBackgroundPlayback: true));
      videoPontroller.addListener(onVideoChange);
      videoPontroller.initialize();
      videoPontroller.play();
    } catch (e) {
      debugPrint('播放错误');
      debugPrint(e.toString());
    }
  }

  void onVideoChange() {
    onPositionChange(videoPontroller.value.position.inMilliseconds);
    if (videoPontroller.value.position == videoPontroller.value.duration) {
      isplaying = false;
      onMusicChange(AppState.musics.isNotEmpty ? AppState.next() : null);
      print('结束');
    }
  }

  void onPositionChange(int t) async {
    lyrcController.emit(MyEventsEnum.setLyricPosition, t);
    if (music == null) {
      return;
    }
    if (music!.isVideo) {
      var dur = videoPontroller.value.duration;
      setState(() {
        preccent = t / dur.inMilliseconds;
      });
    }
    if (music!.isVideo == false) {
      var dur = await audioPlayer.getDuration();
      if (dur == null) {
        return;
      }
      setState(() {
        preccent = t / dur.inMilliseconds;
      });
    }
  }

  void setMedia(Music m) async {
    isplaying = true;

    print('播放：${m.id}');
    if (m.isVideo) {
      audioPlayer.stop();
      lyrcController.emit(MyEventsEnum.setVisible, false);
      createVideoPlayer(m.url);
      //先创建再显示
      setState(() {
        music = m;
        preccent = 0;
      });
    } else {
      setState(() {
        music = m;
        preccent = 0;
      });
      // 先隐藏再销毁
      await videoPontroller.pause();
      videoPontroller.dispose();

      lyrcController.emit(MyEventsEnum.setVisible, true);
      lyrcController.emit(MyEventsEnum.setError, '');
      parseLrc(m.id);
      audioPlayer.play(UrlSource(m.url)).catchError((e) {
        print('播放失败');
        lyrcController.emit(MyEventsEnum.setError, '播放失败');
      });
    }
  }

  void parseLrc(int id) async {
    Map res = await httpUtilGet('/lyric?id=$id');
    if (res['lrc'] == null) {
      lyrcController.emit(MyEventsEnum.setError, '歌词解析失败01');
      return;
    }
    if (res['lrc']['lyric'] == null) {
      lyrcController.emit(MyEventsEnum.setError, '歌词解析失败02');
      return;
    }
    lyrcController.emit(MyEventsEnum.setLyric, res['lrc']['lyric']);
  }

  @override
  Widget build(BuildContext context) {
    String msg = '';
    if (music == null) {
      msg = '没有数据';
    }
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
            child: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        )),
        buildAudioPlayer(),
        buildVideoPlayer(size),
        buildProgress(size),
      ],
    );
  }

  Widget buildProgress(Size size) {
    double w = size.width * preccent;
    return Stack(children: [
      SizedBox(
        width: w.isNaN ? 0 : w,
        height: 5,
        child: const ColoredBox(color: Colors.red),
      )
    ]);
  }

  Widget buildAudioPlayer() {
    return LyrcsReader(lyrcController);
  }

  Widget buildVideoPlayer(Size size) {
    if (music == null) {
      return Container();
    }

    if (music!.isVideo == false ||
        videoPontroller.value.isInitialized == false) {
      return Container();
    }

    return Center(
        child: AspectRatio(
            aspectRatio: videoPontroller.value.aspectRatio,
            child: VideoPlayer(videoPontroller)));
  }
}

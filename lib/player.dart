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

  void createVideoPlayer(String url) {
    try {
      videoPontroller.dispose();
      videoPontroller =
          VideoPlayerController.networkUrl(Uri.parse(httpsGenerate(url)));
      videoPontroller.addListener(() {
        onPositionChange(videoPontroller.value.position.inMilliseconds);
        if (videoPontroller.value.position == videoPontroller.value.duration) {
          isplaying = false;
          onMusicChange(AppState.musics.isNotEmpty ? AppState.next() : null);
          print('结束');
        }
      });
      videoPontroller.initialize();
      videoPontroller.play();
    } catch (e) {
      debugPrint('播放错误');
      debugPrint(e.toString());
    }
  }

  void onPositionChange(int t) async {
    lyrcController.emit(MyEventsEnum.setLyricPosition, t);
    if (music == null) {
      return;
    }
    if (music!.isVideo) {
      //
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

  void setMedia(Music m) {
    isplaying = true;
    if (m.isVideo) {
      audioPlayer.pause();
      lyrcController.emit(MyEventsEnum.setVisible, false);
      createVideoPlayer(m.url);
      //
    } else {
      videoPontroller.pause();
      lyrcController.emit(MyEventsEnum.setVisible, true);
      lyrcController.emit(MyEventsEnum.setError, '');
      parseLrc(m.id);
      audioPlayer.play(UrlSource(m.url)).catchError((e) {
        print('播放失败');
        lyrcController.emit(MyEventsEnum.setError, '播放失败');
      });
    }
    music = m;
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

    return Stack(
      children: [
        buildProgress(context),
        Center(
            child: Text(
          msg,
          style: const TextStyle(color: Colors.white),
        )),
        buildAudioPlayer(),
        buildVideoPlayer(),
      ],
    );
  }

  Widget buildProgress(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(children: [
      SizedBox(
        width: size.width * preccent,
        height: 5,
        child: const ColoredBox(color: Colors.red),
      )
    ]);
  }

  Widget buildAudioPlayer() {
    return LyrcsReader(lyrcController);
  }

  Widget buildVideoPlayer() {
    if (music == null) {
      return const SizedBox();
    }
    if (music!.isVideo) {
      return VideoPlayer(videoPontroller);
    } else {
      return const SizedBox();
    }
  }
}

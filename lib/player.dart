import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'commponents/lyrcs_reader.dart';
import 'utils/app_state.dart';

enum MediaPlayerControllerEvent { setMedia, setMute }

class MediaPlayerController {
  Music? music;
  final Map<MediaPlayerControllerEvent, List<Function>> _events = {};
  void setMedia(Music m) {
    music = m;
    emit(MediaPlayerControllerEvent.setMedia, m);
  }

  void on(MediaPlayerControllerEvent event, Function listener) {
    if (_events[event] != null) {
      _events[event] = [listener];
    } else {
      _events[event]!.add(listener);
    }
  }

  void off(MediaPlayerControllerEvent event, Function listener) {
    var ar = _events[event];
    if (ar != null) {
      ar.remove(listener);
    }
  }

  void emit(MediaPlayerControllerEvent event, arg) {
    var ar = _events[event];
    if (ar != null) {
      for (var func in ar) {
        func(arg);
      }
    }
  }
}

class MediaPlayer extends StatefulWidget {
  final MediaPlayerController controller;
  const MediaPlayer(this.controller, {super.key});
  @override
  State<MediaPlayer> createState() => MediaPlayerState();
}

class MediaPlayerState extends State<MediaPlayer> {
  MediaPlayerState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.music == null) {
      // return const Text(
      //   '没有数据',
      //   style: TextStyle(color: Colors.white),
      // );
      return LyrcsReader();
    } else {
      return buildVideoPlayer();
    }
  }

  Widget buildVideoPlayer() {
    return const Text(
      'video',
      style: TextStyle(color: Colors.white),
    );
  }
}

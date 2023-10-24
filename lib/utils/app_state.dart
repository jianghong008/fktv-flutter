import 'dart:io';

class Music {
  final int duration;
  final String name;
  final String cover;
  final int id;
  final String url;
  final String? lyric;
  final bool isVideo;
  const Music(
      {required this.id,
      required this.duration,
      required this.name,
      required this.cover,
      required this.url,
      required this.isVideo,
      this.lyric});
}

class AppState {
  static final List<Music> musics = [];
  static late Music music;
  static void add(Music m) {
    musics.add(m);
  }

  static void remove(Music m) {
    musics.remove(m);
  }

  static Music next() {
    if (musics.isEmpty) {
      throw Error();
    }
    return musics.last;
  }
}

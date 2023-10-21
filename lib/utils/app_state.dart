class Music {
  final int duration;
  final String title;
  final String coverSrc;
  final String url;
  const Music(
      {required this.duration,
      required this.title,
      required this.url,
      required this.coverSrc});
}

class AppState {
  static final List<Music> musics = [];
  static void add(Music m) {
    musics.add(m);
  }

  static void remove(Music m) {
    musics.remove(m);
  }

  static Music next() {
    return musics.last;
  }
}

class Music {
  final int duration;
  final String name;
  final String cover;
  final int id;
  final String url;
  const Music(
      {required this.id,
      required this.duration,
      required this.name,
      required this.cover,
      required this.url});
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
    musics.add(const Music(
        id: 376199,
        duration: 317490,
        name: '海阔天空',
        cover:
            'http://p1.music.126.net/S8InCa4o-pFJszhUvI-NPQ==/3247957351196805.jpg',
        url:
            'http://vodkgeyttp8.vod.126.net/cloudmusic/IGQwMDQwIDVkICBgNDQhIA==/mv/376199/5508b93dd0abdefe41ce48d54540aca6.mp4?wsSecret=12bedf80c248e6ff9b08ca47f8cb8099&wsTime=1697965608'));
    if (musics.isEmpty) {
      throw Error();
    }
    return musics.last;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'utils/app_state.dart';
import 'utils/net_utils.dart';

var apiJson = {'code': 0, 'msg': 'ok', 'data': null};

class AppHttpServer {
  late final HttpServer _server;
  String ip = '127.0.0.1';
  late Function onMusicChane;
  VideoPlayerController? curPlayer;
  double volume = 1;
  Future<void> start() async {
    init();
    ip = await getIP();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 8848);
    print('server is running');
    _server.forEach((req) async {
      try {
        await handle(req);
      } catch (e) {
        print(e);
      }
      req.response.close();
    });
  }

  stop() async {
    await _server.close();
  }

  void init() {
    //String lyric = await File('/sdcard/Documents/lyric.txt').readAsString();
  }

  handle(HttpRequest req) async {
    req.response.headers.contentType = ContentType.json;
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', '*');
    req.response.headers.add('Access-Control-Allow-Headers', '*');
    // api
    if (RegExp('^/api').hasMatch(req.uri.path)) {
      String memberName = req.uri.path.replaceAll(RegExp(r'(/api|/)'), '');
      switch (memberName) {
        case 'next':
          next(req);
          break;
        case 'add':
          await add(req);
          break;
        case 'remove':
          remove(req);
          break;
        case 'list':
          list(req);
          break;
        case 'mute':
          mute(req);
          break;
        default:
          req.response.write('404');
      }
      apiJson['data'] = null;
      apiJson['code'] = 1;
      apiJson['msg'] = 'ok';
      return;
    }
    req.response.write('hello');
  }

  VideoPlayerController createPlayer(String url) {
    var player =
        VideoPlayerController.networkUrl(Uri.parse(httpsGenerate(url)));
    curPlayer = player;
    return player;
  }

  void next(HttpRequest req) {
    try {
      // init();
      onMusicChane.call(AppState.next());
      req.response.write('切歌');
    } catch (e) {
      apiJson['msg'] = '请先添加歌曲';
      req.response.statusCode = 404;
      apiJson['code'] = 404;
      req.response.write(apiJson);
    }
  }

  add(HttpRequest req) async {

    if (req.method == 'POST') {
      
      var str = await utf8.decoder.bind(req).join();
      var data = json.decode(str);
      AppState.add(Music(
          id: data['id'],
          duration: data['duration'],
          name: data['name'],
          cover: data['cover'],
          url: data['url'],
          isVideo: true));
      //只有一首直接播放
      if(AppState.musics.length==1){
        onMusicChane.call(AppState.next());
      }

      print('添加成功');
      apiJson['code'] = 200;
      apiJson['data'] = 1;
      req.response.write(apiJson);
    } else {
      apiJson['msg'] = '请求不允许';
      apiJson['code'] = 405;
      
      req.response.statusCode = 405;
      req.response.write(apiJson);
    }
  }

  void remove(HttpRequest req) {}
  void list(HttpRequest req) {
    apiJson['data'] = AppState.musics;
    apiJson['code'] = 0;
    req.response.write(apiJson);
  }

  void mute(HttpRequest req) {
    if (req.method == 'POST') {
      apiJson['code'] = 0;
      req.response.write(apiJson);
    } else {
      apiJson['code'] = 1;
      apiJson['msg'] = '请求不允许';
      req.response.write(apiJson);
    }
    if (curPlayer != null) {
      volume = volume > 0 ? 0 : 1;
      curPlayer!.setVolume(volume);
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'api/netease_cloud_music.dart';

Future<HttpServer> startApiServer({address = "127.0.0.1", int port = 8849}) {
  return HttpServer.bind(address, port, shared: true).then((server) {
    debugPrint("start listen at: http://$address:$port");
    server.listen((request) {
      _handleRequest(request);
    });
    return server;
  });
}

void _handleRequest(HttpRequest request) async {
  if (request.uri.path == '/favicon.ico') {
    request.response.statusCode = 404;
    request.response.close();
    return;
  }
  final answer = await cloudMusicApi(request.uri.path,
          parameter: request.uri.queryParameters, cookie: request.cookies)
      .catchError((e, s) async {
    debugPrint(e.toString());
    debugPrint(s.toString());
    return const Answer();
  });
  request.response.headers.add('Access-Control-Allow-Origin', '*');
  request.response.headers.add('Access-Control-Allow-Methods', '*');
  request.response.headers.add('Access-Control-Allow-Headers', '*');
  request.response.statusCode = answer.status;
  request.response.cookies.addAll(answer.cookie);
  request.response.write(json.encode(answer.body));
  request.response.close();

  debugPrint("request[${answer.status}] : ${request.uri}");
}
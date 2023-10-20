import 'dart:io';

class AppHttpServer {
  late final HttpServer _server;
  String ip = '127.0.0.1';
  start() async {
    ip = await getIP();
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 8848);
    print('server is running');
    _server.forEach((req) {
      req.response.write('hello');
      req.response.close();
    });
  }

  stop() async {
    await _server.close();
  }

  getIP() async {
    List<NetworkInterface> list = await NetworkInterface.list();
    List<String> ips = [];
    for (NetworkInterface net in list) {
      for (var ip in net.addresses) {
        if (ip.type == InternetAddressType.IPv4 &&
            ip.address.isNotEmpty &&
            ip.address != '127.0.0.1') {
          ips.add(ip.address);
        }
      }
    }
    String ip = ips.first.isEmpty ? '127.0.0.1' : ips.first;
    for (String temp in ips) {
      if (temp.contains('192.')) {
        ip = temp;
      }
    }
    return ip;
  }
}

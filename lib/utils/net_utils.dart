import 'dart:convert';
import 'dart:io';

Future<String> getIP() async {
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

String httpsGenerate(String url) {
  return url.replaceAll('http://', 'https://');
}

httpUtilGet(String url) async {
  var client = HttpClient();
  var request = await client.getUrl(Uri.parse('http://127.0.0.1:8849$url'));
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  client.close();
  return json.decode(responseBody);
}

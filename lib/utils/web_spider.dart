import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';

class WebSpider {
  static const String host = 'haokan.baidu.com';
  static const int port = 443;
  static const String apiVersion = '1';
  static List cookies = [];
  static HttpClient client = HttpClient();

  static Future<String> loadUrl(
      String path, Map<String, dynamic>? q, bool init) async {
    HttpClientRequest req = await client.getUrl(Uri.https(host, path, q));
    // print(Uri.https(host, path, q));
    setHeaders(req);
    HttpClientResponse res = await req.close();
    cookies = res.cookies;
    String str = await res.transform(utf8.decoder).join();
    return str;
  }

  static void init() {
    WebSpider.loadUrl('', {}, true);
  }

  static setHeaders(HttpClientRequest req) {
    req.headers.add('cookie', cookies);
    const uas = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.57',
      'Mozilla/5.0 (X11; U; Linux x86_64; zh-CN; rv:1.9.2.10) Gecko/20100922 Ubuntu/10.10 (maverick) Firefox/3.6.10',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36',
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; QQDownload 732; .NET4.0C; .NET4.0E; LBBROWSER)"',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.122 UBrowser/4.0.3214.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2'
    ];
    int uasIndex = Random().nextInt(uas.length);
    req.headers.set('user-agent', uas[uasIndex]);
  }

  /// 搜索
  static Future<String> hkSearch(Map<String, String> m) async {
    String query = "${m['q'] ?? ''} mv";
    String pn = m['pn'] ?? '1';
    String rn = m['rn'] ?? '10';
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String s =
        [pn, Uri.encodeComponent(query), rn, timestamp, apiVersion].join('_');
    String type = 'video';
    Digest d = md5.convert(utf8.encode(s));
    String sign = d.toString();
    var queryMap = {
      'query': query,
      'pn': pn,
      'rn': rn,
      'sign': sign,
      'type': type,
      'timestamp': timestamp.toString(),
      'version': apiVersion
    };

    String path = "/haokan/ui-search/pc/search/video";
    var res = await loadUrl(path, queryMap, false);
    return res;
  }

  /// mv详情
  static Future<String> hkMvFromVID(String vid) async {
    String res = await loadUrl('/v', {'vid': vid}, false);
    RegExp reg = RegExp(
        r'window\.__PRELOADED_STATE__ =[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>');
    var temp = reg.stringMatch(res);
    if (temp == null) {
      throw Error();
    }
    temp = temp.replaceAll(
        RegExp(
            r'(<\/script>|window\.__PRELOADED_STATE__ =)|document.querySelector.+|;'),
        '');
    return temp;
  }
}

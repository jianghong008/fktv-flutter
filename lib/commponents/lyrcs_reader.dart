import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LyrcsData {
  String lyric = "";
  Map<String, String> map = {};
  load(String s) {
    var reg = RegExp(r'[\d\D](?:[^\\n])*\\n', dotAll: true);
    var timeReg = RegExp(r'\[\d{2}:\d{2}[\.\d]*\]');
    var matches = reg.allMatches(s);
    for (var match in matches) {
      String line = match.group(0)!;
      var m = timeReg.stringMatch(line);
      if (m == null || m.isEmpty) {
        continue;
      }
      var ctx = line.replaceAll(m, '');
      m = m.replaceAll(RegExp(r'[\[\]]'), '');
      map[m] = ctx.replaceAll(RegExp(r'[\n\\n]'), '');
    }
  }

  Widget render(String t) {
    var t1 = "";
    var t2 = "";
    var t3 = "";
    var n = false;
    for (var m in map.entries) {
      if (m.key == t) {
        t2 = m.value;
        n = true;
      } else if (n) {
        t3 = m.value;
      } else {
        t1 = m.value;
      }
    }
    var style = const TextStyle(
        color: Color.fromARGB(255, 183, 183, 183), fontSize: 16);
    var text1 = Text(t1, style: style);
    var text2 = Text(t2,
        style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 18));
    var text3 = Text(t3, style: style);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              children: [text1],
            ),
            Wrap(
              children: [text2],
            ),
            Wrap(
              children: [text3],
            )
          ],
        )
      ],
    );
  }
}

class LyrcsReader extends StatefulWidget {
  const LyrcsReader({super.key});
  @override
  State<StatefulWidget> createState() => LyrcsReaderState();
}

class LyrcsReaderState extends State {
  String lyric = "";
  LyrcsData lrc = LyrcsData();
  final MethodChannel channel = const MethodChannel('test');
  @override
  void initState() {
    super.initState();
    parseLrc();
  }

  void parseLrc() async {
    var s = await File('sdcard/Documents/gc.txt').readAsString();
    setState(() {});
    lrc.load(s);
    var mp3 =
        'http://m7.music.126.net/20231126173114/e42edbf761983cf4c57929cd31d7b71f/ymusic/57d6/ba78/a6d6/30ae02ed850a7fc4612d4111aada0817.mp3';
    var res = await channel.invokeMethod('hello');
    debugPrint(res.toString());
  }

  @override
  Widget build(BuildContext context) {
    return lrc.render('00:46.353');
  }
}

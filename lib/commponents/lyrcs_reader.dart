import 'package:flutter/material.dart';
import '../utils/events.dart';

class LyrcsController extends MyEvents {
  void setPosition(int m) {
    emit(MyEventsEnum.setLyricPosition, m);
  }

  void setLyric(String m) {
    emit(MyEventsEnum.setLyric, m);
  }
}

class LyrcsData {
  String lyric = "";
  String lastLine = "";
  int step = 600;
  Map<double, String> map = {};
  void load(String s) {
    map.clear();
    lyric = s;
    var reg = RegExp(r'[\d\D](?:[^\\n\n])*(\\n|\n)', dotAll: true);
    var timeReg = RegExp(r'\[\d{2}:\d{2}[\.\d]*\]', dotAll: true);
    var matches = reg.allMatches(s);
    for (var match in matches) {
      String line = match.group(0)!;
      var times = timeReg.allMatches(line);
      for (var time in times) {
        String m = time.group(0)!;
        var ctx = line.replaceAll(m, '');
        m = m.replaceAll(RegExp(r'[\[\]\n\\\n]', dotAll: true), '');
        //time
        List<String> str = m.split(':');
        if (str.length != 2) {
          continue;
        }
        double kt = double.parse(str[0]) * 60 + double.parse(str[1]);
        String val = ctx.replaceAll(RegExp(r'[\n\\n]'), '');
        val = val.replaceAll(timeReg, '');
        map[kt] = val;
      }
    }
    //map按key排序
    map = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  Widget render(int t) {
    var t1 = "";
    var t2 = "";
    var t3 = "";
    List<String> arr = [];
    for (var m in map.entries) {
      arr.add(m.value);

      if (m.key * 1000 <= t + step) {
        t2 = m.value;
      }
    }
    if (t2 == '') {
      t2 = lastLine;
    }
    if (t2 != '') {
      int index = arr.indexOf(t2);
      lastLine = t2;
      if (index > 0) {
        t1 = arr[index - 1];
      }
      if (index < arr.length - 1) {
        t3 = arr[index + 1];
      }
    }

    var style = const TextStyle(
        color: Color.fromARGB(255, 183, 183, 183), fontSize: 16);
    var text1 = Text(t1, style: style);
    var text2 = Text(t2,
        style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 20));
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
  final LyrcsController controller;
  const LyrcsReader(this.controller, {super.key});
  @override
  State<StatefulWidget> createState() => LyrcsReaderState();
}

class LyrcsReaderState extends State<LyrcsReader> {
  LyrcsData lrc = LyrcsData();
  bool visible = true;
  int currentPosition = 0;
  String error = '';
  @override
  void initState() {
    super.initState();
    widget.controller.on(MyEventsEnum.setVisible, setVisible);
    widget.controller.on(MyEventsEnum.setLyric, setLyric);
    widget.controller.on(MyEventsEnum.setLyricPosition, setPosition);
    widget.controller.on(MyEventsEnum.setError, setError);
  }

  void setError(String err) {
    setState(() {
      error = err;
    });
  }

  void setVisible(bool val) {
    setState(() {
      visible = val;
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.off(MyEventsEnum.setLyric, setLyric);
    widget.controller.off(MyEventsEnum.setLyricPosition, setPosition);
  }

  void setLyric(String s) {
    lrc.load(s);
    setPosition(1);
  }

  void setPosition(int m) {
    setState(() {
      currentPosition = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error != '') {
      return Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return visible ? lrc.render(currentPosition) : Container();
  }
}

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'utils/net_utils.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});
  @override
  State<StatefulWidget> createState() {
    return ScanQrcodeState();
  }
}

class ScanQrcodeState extends State<ScanQrcode> {
  var qrImage;
  final String webRemote = 'http://jhpw.gitee.io/fktv-webui/';
  @override
  void initState() {
    super.initState();
    final qrCode = QrCode(8, QrErrorCorrectLevel.H);
    qrCode.addData('请稍后...');
    qrImage = QrImage(qrCode);
    getIP().then((value) => initQr(value));
  }

  void initQr(String str) {
    final qrCode = QrCode(8, QrErrorCorrectLevel.H);
    qrCode.addData("$webRemote?host=$str");
    setState(() {
      qrImage = QrImage(qrCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.fromLTRB(20, size.height - 150, 0, 0),
        child: SizedBox(
          width: 100,
          child: Column(
            children: [
              const Text(
                '扫码点歌',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                color: Colors.white,
                child: PrettyQrView(
                  qrImage: qrImage,
                  decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(
                          color: Color.fromARGB(255, 0, 140, 255))),
                ),
              )
            ],
          ),
        ));
  }
}

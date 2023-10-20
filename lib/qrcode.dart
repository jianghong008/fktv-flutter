import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ScanQrcode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScanQrcodeState();
  }
}

class ScanQrcodeState extends State<ScanQrcode> {
  var qrImage;
  @override
  void initState() {
    super.initState();
    final qrCode = QrCode(8, QrErrorCorrectLevel.H);
    qrCode.addData('hello');
    qrImage = QrImage(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        padding: EdgeInsets.fromLTRB(20, size.height - 120, 0, 0),
        child: SizedBox(
          width: 100,
          child: Container(
            color: Colors.white,
            child: PrettyQrView(
              qrImage: qrImage,
              decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                      color: Color.fromARGB(255, 0, 140, 255))),
            ),
          ),
        ));
  }
}

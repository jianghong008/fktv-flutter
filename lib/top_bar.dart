import 'package:flutter/material.dart';

class MyTopBar extends StatefulWidget {
  final String title;
  const MyTopBar({super.key, required this.title});

  @override
  State<StatefulWidget> createState() => TopBarState();
}

class TopBarState extends State<MyTopBar> {
  @override
  Widget build(BuildContext context) {
    String title = widget.title;
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Wrap(
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold))
          ],
        )
      ]),
    );
  }
}

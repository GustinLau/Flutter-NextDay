import 'dart:ui';

import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Container(
        color: Colors.black38.withOpacity(0.5),
        child: Column(children: [
          AppBar(
            title: Center(child: Text('关于')),
            backgroundColor: Colors.transparent,
            leading: Container(),
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/icons/close.png',
                    width: 24, height: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
              child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '这是一个Flutter的练习项目。\n(而且写得比较渣~还不能选日期)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    decoration: TextDecoration.none),
              ),
            ),
          ))
        ]),
      ),
    );
  }
}

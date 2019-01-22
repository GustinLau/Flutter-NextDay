import 'dart:ui';

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('关于'),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset('assets/icons/back.png', width: 24, height: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
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
          ),
        ),
      ),
    );
  }
}

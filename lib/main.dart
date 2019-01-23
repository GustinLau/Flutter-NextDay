import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/page/home/home_page.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int lastClickTime = 0;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      home: BlocProvider(
          bloc: HomePageBloc(),
          child: WillPopScope(
              onWillPop: () {
                int nowTime = DateTime.now().microsecondsSinceEpoch;
                if (lastClickTime != 0 && nowTime - lastClickTime > 1500) {
                  MusicPlayerBloc.instance.dispose();
                  return Future.value(true);
                } else {
                  Fluttertoast.showToast(
                      msg: "再按一次退出",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.black.withAlpha(200),
                      textColor: Colors.white);
                  lastClickTime = new DateTime.now().microsecondsSinceEpoch;
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    lastClickTime = 0;
                  });
                  return Future.value(false);
                }
              },
              child: HomePage())),
    );
  }
}

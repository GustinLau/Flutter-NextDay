import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/page/home/home_page.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    int lastClickTime = 0;
    return MaterialApp(
      home: WillPopScope(
          onWillPop: (){
            int nowTime = new DateTime.now().microsecondsSinceEpoch;
            if (lastClickTime != 0 && nowTime - lastClickTime > 1500) {
              MusicPlayerBloc.instance.dispose();
              return new Future.value(true);
            } else {
              Fluttertoast.showToast(
                  msg: "再按一次退出",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.black.withAlpha(200),
                  textColor: Colors.white);
              lastClickTime = new DateTime.now().microsecondsSinceEpoch;
              new Future.delayed(const Duration(milliseconds: 1500), () {
                lastClickTime = 0;
              });
              return new Future.value(false);
            }
          },
          child: BlocProvider(bloc: HomePageBloc(), child: HomePage())),
    );
  }
}

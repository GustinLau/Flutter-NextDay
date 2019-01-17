import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/widget/day/day.dart';
import 'package:next_day/widget/day/day_bloc.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    HomePageBloc bloc = BlocProvider.of(context);
    return StreamBuilder<HomePageState>(
        stream: bloc.stream,
        initialData: bloc.state,
        builder: (BuildContext context, AsyncSnapshot<HomePageState> snapshot) {
          HomePageState state = snapshot.data;
          return Container(
            color: Colors.white,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  // 开始滑动
                  bloc.setScrolling(true);
                }
                if (notification is ScrollEndNotification) {
                  // 结束滑动
                  bloc.setScrolling(false);
                }
              },
              child: PageView.builder(
                  controller: PageController(viewportFraction: 1),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.dayInfoMap.length,
                  reverse: true,
                  physics: state.canScroll
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) {
                    MusicPlayerBloc.instance.updateMusic(
                        state.dayInfoMap[bloc.keyWithOffset(i)].music);
                    if (i == state.dayInfoMap.length - 1) {
                      bloc.getInfoWithOffset(i + 1);
                    }
                  },
                  itemBuilder: (context, i) {
                    String key = bloc.keyWithOffset(i);
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: BlocProvider(
                            bloc: DayBloc(
                                homePageBloc: bloc,
                                info: state.dayInfoMap.containsKey(key)
                                    ? state.dayInfoMap[key]
                                    : null),
                            child: Day(),
                          ),
                        )
                      ],
                    );
                  }),
            ),
          );
        });
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/util/adaptation_utils.dart';
import 'package:next_day/widget/day/day.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    GlobalKey globalKey = GlobalKey();
    HomePageBloc bloc = BlocProvider.of(context);
    bloc.setGlobalKey(globalKey);
    return StreamBuilder<HomePageState>(
        stream: bloc.stream,
        initialData: bloc.state,
        builder: (BuildContext context, AsyncSnapshot<HomePageState> snapshot) {
          HomePageState state = snapshot.data;
          return RepaintBoundary(
            key: globalKey,
            child: Container(
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
                child: GestureDetector(
                  onVerticalDragDown: !state.canScroll
                      ? null
                      : (DragDownDetails details) =>
                          bloc.setStartDragPosition(details.globalPosition),
                  onVerticalDragStart: !state.canScroll
                      ? null
                      : (DragStartDetails details) => bloc.setDragging(true),
                  onVerticalDragUpdate: !state.canScroll
                      ? null
                      : (DragUpdateDetails details) {
                          bloc.setDragDirection(details.delta.direction);
                          bloc.setCurrentDragPosition(details.globalPosition);
                        },
                  onVerticalDragEnd: !state.canScroll
                      ? null
                      : (DragEndDetails details) {
                          bloc.setDragging(false);
                        },
                  child: Stack(children: [
                    PageView.builder(
                        controller: PageController(viewportFraction: 1),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.dayInfoMap.length,
                        reverse: true,
                        physics: state.canScroll
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) {
                          String key = bloc.keyWithOffset(i);
                          MusicPlayerBloc.instance.updateMusic(
                              state.dayInfoMap[bloc.keyWithOffset(i)].music);
                          bloc.setCurrentInfo(state.dayInfoMap.containsKey(key)
                              ? state.dayInfoMap[key]
                              : null);
                          if (i == state.dayInfoMap.length - 1) {
                            bloc.getInfoWithOffset(i + 1);
                          }
                        },
                        itemBuilder: (context, i) {
                          String key = bloc.keyWithOffset(i);
                          return Column(
                            children: <Widget>[
                              Expanded(
                                child: Day(
                                    info: state.dayInfoMap.containsKey(key)
                                        ? state.dayInfoMap[key]
                                        : null,
                                    showMainView: state.canScroll,
                                    hideAllView: state.isScrolling),
                              )
                            ],
                          );
                        }),
                    state.dragPercent >= 0
                        ? Container()
                        : Container(
                            child: Stack(
                            children: <Widget>[
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: -state.dragPercent * 15.0,
                                    sigmaY: -state.dragPercent * 15.0),
                                child: Container(
                                    color: state.currentInfo != null
                                        ? Color((int.parse(
                                                    state.currentInfo.colors
                                                        .background
                                                        .substring(1),
                                                    radix: 16)) |
                                                0xFF000000)
                                            .withOpacity(
                                                -state.dragPercent * 0.5)
                                        : Colors.black38.withOpacity(
                                            -state.dragPercent * 0.5)),
                              ),
                              Opacity(
                                opacity: -state.dragPercent,
                                child: GestureDetector(
                                  onTap: () {
                                    bloc.showSetting(context);
                                  },
                                  child: Center(
                                    child: Image.asset('assets/icons/setting.png',
                                        width: AdaptationUtils.adaptWidth(70),
                                        height: AdaptationUtils.adaptWidth(70)),
                                  ),
                                ),
                              )
                            ],
                          ))
                  ]),
                ),
              ),
            ),
          );
        });
  }
}

import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/util/adaptation_utils.dart';
import 'package:next_day/widget/day/day_bloc.dart';
import 'package:next_day/widget/music_player/music_player.dart';

class Day extends StatelessWidget {
  static const List<String> MONTHS = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
  static const List<String> WEEKS = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY'
  ];

  // 日期
  Widget _date(DayState state) {
    return Container(
      height: AdaptationUtils.adaptHeight(130),
      margin: EdgeInsets.only(
          left: AdaptationUtils.adaptWidth(16),
          right: AdaptationUtils.adaptWidth(16),
          bottom: AdaptationUtils.adaptHeight(5)),
      child: Text(
        state.info.dateKey.substring(6),
        style: TextStyle(
            shadows: const [
              const Shadow(
                  color: Color(0x88000000), offset: Offset(2, 2), blurRadius: 4)
            ],
            fontFamily: 'Prompt',
            fontWeight: FontWeight.w100,
            color: Colors.white,
            letterSpacing: 5,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.adaptWidth(120)),
      ),
    );
  }

  // 月份 星期 特别日子
  Widget _dateInfo(DayState state) {
    return Container(
      margin: EdgeInsets.only(
          left: AdaptationUtils.adaptWidth(16),
          right: AdaptationUtils.adaptWidth(16),
          bottom: AdaptationUtils.adaptWidth(28)),
      child: Text(
        '${MONTHS[state.info.getDateTime().month - 1]}.${WEEKS[state.info.getDateTime().weekday - 1]}' +
            (state.info.event == null ? '' : ',${state.info.event}'),
        style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.w300,
            shadows: const [
              const Shadow(
                  color: Color(0x88000000), offset: Offset(2, 2), blurRadius: 4)
            ],
            letterSpacing: 1,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.adaptWidth(22)),
      ),
    );
  }

  // 地点
  Widget _geo(DayState state) {
    return Container(
      padding: EdgeInsets.only(
          left: AdaptationUtils.adaptWidth(16),
          right: AdaptationUtils.adaptWidth(16),
          bottom: AdaptationUtils.adaptHeight(4)),
      child: Text(
        state.info.geo.reverse,
        style: TextStyle(
            fontFamily: 'PingFang',
            shadows: const [
              const Shadow(
                  color: Color(0x88000000), offset: Offset(2, 2), blurRadius: 4)
            ],
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.adaptWidth(13)),
      ),
    );
  }

  // 描述
  Widget _desc(DayState state) {
    return Container(
      margin: EdgeInsets.only(
        left: AdaptationUtils.adaptWidth(16),
        right: AdaptationUtils.adaptWidth(16),
      ),
      padding: const EdgeInsets.only(left: 4, right: 4),
      color: Color(
          (int.parse(state.info.colors.background.substring(1), radix: 16)) |
              0xFF000000),
      child: Text(
        state.info.text.short,
        style: TextStyle(
            fontFamily: 'PingFang',
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.adaptWidth(14)),
      ),
    );
  }

  // 音乐播放器
  Widget _musicPlayer(DayState state) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: const LinearGradient(
          colors: const [
            const Color(0x88000000),
            Colors.transparent,
          ],
          stops: <double>[0, 1],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
            left: AdaptationUtils.adaptWidth(16),
            right: AdaptationUtils.adaptWidth(16),
            top: AdaptationUtils.adaptHeight(40),
            bottom: AdaptationUtils.safeAreaBottom),
        height:
            (AdaptationUtils.safeAreaBottom + AdaptationUtils.adaptHeight(100)),
        child: Stack(
          children: <Widget>[
            MusicPlayer(musicModel: state.info.music),
            Container(
              height: AdaptationUtils.adaptHeight(35),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  state.info.author == null ? '' : '@${state.info.author.name}',
                  style: TextStyle(
                      color: const Color(0xEEEEEEEE),
                      fontFamily: 'PingFang',
                      fontSize: AdaptationUtils.adaptWidth(13),
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 图片
  Widget _image(DayState state) {
    return Container(
      child: CachedNetworkImage(
        placeholder: const Center(child: const CircularProgressIndicator()),
        imageUrl: InfoModel.realImagePath(AdaptationUtils.safeAreaBottom > 0
            ? state.info.images['iphone-x']
            : state.info.images['big568h2x']),
        fit: BoxFit.cover,
      ),
    );
  }

  // 主界面
  Widget _mainView(DayState state) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: state.hideAllView ? 0 : (state.showMainView ? 1 : 0),
      child: Container(
        color: Colors.transparent,
        child: Column(
          verticalDirection: VerticalDirection.up,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 音乐播放器
            _musicPlayer(state),
            _desc(state),
            _geo(state),
            _dateInfo(state),
            _date(state),
          ],
        ),
      ),
    );
  }

  // 下载界面
  Widget _downloadView(DayState state) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: state.hideAllView ? 0 : (state.showMainView ? 0 : 1),
      child: GestureDetector(
        onTap: state.hideAllView || state.showMainView
            ? null
            : () async {
                String uri = InfoModel.realImagePath(
                    AdaptationUtils.safeAreaBottom > 0
                        ? state.info.images['iphone-x']
                        : state.info.images['big568h2x']);
                ByteData bytes =
                    await NetworkAssetBundle(Uri.base.resolve(uri)).load(uri);
                // TODO 保存
              },
        child: Container(
          padding: EdgeInsets.only(bottom: AdaptationUtils.safeAreaBottom + 40),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/icons/save.png',
                width: AdaptationUtils.adaptWidth(60),
                height: AdaptationUtils.adaptHeight(60)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DayBloc dayBloc = BlocProvider.of(context);
    return StreamBuilder<DayState>(
        stream: dayBloc.stream,
        initialData: dayBloc.state,
        builder: (BuildContext context, AsyncSnapshot<DayState> snapshot) {
          DayState state = snapshot.data;
          return state.info == null
              ? Container()
              : Container(
                  child: GestureDetector(
                    onTap: () {
                      dayBloc.toggleView();
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        _image(snapshot.data),
                        Stack(
                          children: <Widget>[
                            _mainView(snapshot.data),
                            _downloadView(snapshot.data)
                          ],
                        )
                      ],
                    ),
                  ),
                );
        });
  }
}

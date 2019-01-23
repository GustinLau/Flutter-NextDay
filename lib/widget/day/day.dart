import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/util/adaptation_utils.dart';
import 'package:next_day/widget/music_player/music_player.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

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

  final InfoModel info;
  final bool showMainView;
  final bool hideAllView;

  Day({this.info, this.showMainView, this.hideAllView});

  // 日期
  Widget _date() {
    return Container(
      margin: EdgeInsets.only(
          left: AdaptationUtils.instance.adaptWidth(16),
          right: AdaptationUtils.instance.adaptWidth(16)),
      child: Text(
        info.dateKey.substring(6),
        style: TextStyle(
            shadows: const [
              const Shadow(
                  color: Color(0x66000000), offset: Offset(2, 2), blurRadius: 5)
            ],
            fontFamily: 'SourceHanSansCN',
            fontWeight: FontWeight.w200,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.instance.adaptWidth(150)),
      ),
    );
  }

  // 月份 星期 特别日子
  Widget _dateInfo() {
    return Container(
      margin: EdgeInsets.only(
          left: AdaptationUtils.instance.adaptWidth(16),
          right: AdaptationUtils.instance.adaptWidth(16),
          bottom: AdaptationUtils.instance.adaptWidth(80)),
      child: Text(
        '${MONTHS[info.getDateTime().month - 1]}.${WEEKS[info.getDateTime().weekday - 1]}' +
            (info.event == null ? '' : ',${info.event}'),
        style: TextStyle(
            fontFamily: 'SourceHanSansCN',
            fontWeight: FontWeight.w300,
            shadows: const [
              const Shadow(
                  color: Color(0x66000000), offset: Offset(2, 2), blurRadius: 4)
            ],
            letterSpacing: 1.8,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.instance.adaptWidth(22)),
      ),
    );
  }

  // 地点
  Widget _geo() {
    return Container(
      padding: EdgeInsets.only(
          left: AdaptationUtils.instance.adaptWidth(16),
          right: AdaptationUtils.instance.adaptWidth(16),
          bottom: AdaptationUtils.instance.adaptHeight(6)),
      child: Text(
        info.geo.reverse,
        style: TextStyle(
            fontFamily: 'SourceHanSansCN',
            shadows: const [
              const Shadow(
                  color: Color(0x66000000), offset: Offset(2, 2), blurRadius: 4)
            ],
            color: Colors.white,
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.instance.adaptWidth(13.5)),
      ),
    );
  }

  // 描述
  Widget _desc() {
    return Container(
      margin: EdgeInsets.only(
        left: AdaptationUtils.instance.adaptWidth(16),
        right: AdaptationUtils.instance.adaptWidth(16),
      ),
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 2, top: 2),
      color: Color(
          (int.parse(info.colors.background.substring(1), radix: 16)) |
              0xFF000000),
      child: Text(
        info.text.short,
        style: TextStyle(
            fontFamily: 'SourceHanSansCN',
            fontWeight: FontWeight.w300,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontSize: AdaptationUtils.instance.adaptWidth(14)),
      ),
    );
  }

  // 音乐播放器
  Widget _musicPlayer() {
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
            left: AdaptationUtils.instance.adaptWidth(16),
            right: AdaptationUtils.instance.adaptWidth(16),
            top: AdaptationUtils.instance.adaptHeight(50),
            bottom: AdaptationUtils.instance.safeAreaBottom),
        height:
            (AdaptationUtils.instance.safeAreaBottom + AdaptationUtils.instance.adaptHeight(110)),
        child: Stack(
          children: <Widget>[
            MusicPlayer(musicModel: info.music),
            _author()
          ],
        ),
      ),
    );
  }

  // 照片作者
  Widget _author() {
    return Container(
      height: AdaptationUtils.instance.adaptHeight(35),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Text(
          info.author == null ? '' : '@${info.author.name}',
          style: TextStyle(
              color: const Color(0x88EEEEEE),
              fontFamily: 'SourceHanSansCN',
              fontSize: AdaptationUtils.instance.adaptWidth(12),
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }

  // 图片
  Widget _image() {
    return Container(
      child: CachedNetworkImage(
        placeholder: const Center(child: const CircularProgressIndicator()),
        imageUrl: InfoModel.realImagePath(AdaptationUtils.instance.safeAreaBottom > 0
            ? info.images['iphone-x']
            : info.images['big568h3x']),
        fit: BoxFit.cover,
      ),
    );
  }

  // 主界面
  Widget _mainView() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hideAllView ? 0 : (showMainView ? 1 : 0),
      child: Container(
        color: Colors.transparent,
        child: Column(
          verticalDirection: VerticalDirection.up,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _musicPlayer(),
            _desc(),
            _geo(),
            _dateInfo(),
            _date(),
          ],
        ),
      ),
    );
  }

  // 分享
  Widget _shareView(HomePageBloc bloc) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: hideAllView ? 0 : (showMainView ? 0 : 1),
      child: GestureDetector(
        onTap: hideAllView || showMainView
            ? null
            : () async {
          MusicPlayerBloc.instance.hide(true);
          bloc.setCanScroll(!bloc.state.canScroll);
                Future.delayed(
                    const Duration(milliseconds: 300), () => bloc.share());
              },
        child: Container(
          padding: EdgeInsets.only(bottom: AdaptationUtils.instance.safeAreaBottom + 40),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/icons/share.png',
                width: AdaptationUtils.instance.adaptWidth(60),
                height: AdaptationUtils.instance.adaptHeight(60)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomePageBloc bloc = BlocProvider.of(context);
    return info == null
        ? Container()
        : Container(
            child: GestureDetector(
              onTap: () {
                bloc.setCanScroll(!bloc.state.canScroll);
              },
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _image(),
                  Stack(
                    children: <Widget>[
                      _mainView(),
                      _shareView(bloc)
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
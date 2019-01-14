import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:next_day/component/music_player_component.dart';
import 'package:next_day/model/info_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:next_day/util/adaptation_utils.dart';

class DayComponent extends StatefulWidget {
  final InfoModel info;
  final ValueChanged<bool> onToggleOpacity;
  final ValueGetter<bool> shouldHideItems;

  DayComponent({Key key, this.info, this.onToggleOpacity, this.shouldHideItems})
      : super(key: key);

  @override
  _DayComponentState createState() => _DayComponentState(
      info: info,
      onToggleOpacity: onToggleOpacity,
      shouldHideItems: shouldHideItems);
}

class _DayComponentState extends State<DayComponent> {
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
  final ValueChanged<bool> onToggleOpacity;
  final ValueGetter<bool> shouldHideItems;

  double opacityLevel = 1.0;

  _DayComponentState(
      {Key key, this.info, this.onToggleOpacity, this.shouldHideItems});

  @override
  Widget build(BuildContext context) {
    if (info != null && info != InfoModel.empty) {
      return Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              child: CachedNetworkImage(
                placeholder:
                    const Center(child: const CircularProgressIndicator()),
                imageUrl: InfoModel.realImagePath(
                    AdaptationUtils.safeAreaBottom > 0
                        ? info.images['iphone-x']
                        : info.images['big568h2x']),
                fit: BoxFit.cover,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
                onToggleOpacity(opacityLevel == 1);
              },
              child: Stack(
                children: <Widget>[
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: shouldHideItems() ? 0 : opacityLevel,
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        verticalDirection: VerticalDirection.up,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 音乐播放器
                          DecoratedBox(
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
                              height: (AdaptationUtils.safeAreaBottom +
                                  AdaptationUtils.adaptHeight(100)),
                              child: Stack(
                                children: <Widget>[
                                  MusicPlayerComponent(
                                      musicModel: info.music,
                                      canTogglePlayer: () => opacityLevel == 1),
                                  Container(
                                    height: AdaptationUtils.adaptHeight(35),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        info.author == null
                                            ? ''
                                            : '@${info.author.name}',
                                        style: TextStyle(
                                            color: const Color(0xEEEEEEEE),
                                            fontFamily: 'PingFang',
                                            fontSize:
                                                AdaptationUtils.adaptWidth(13),
                                            fontWeight: FontWeight.normal,
                                            decoration: TextDecoration.none),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 描述
                          Container(
                            margin: EdgeInsets.only(
                                left: AdaptationUtils.adaptWidth(16),
                                right: AdaptationUtils.adaptWidth(16)),
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            color: Color((int.parse(
                                    info.colors.background.substring(1),
                                    radix: 16)) |
                                0xFF000000),
                            child: Text(
                              info.text.short,
                              style: TextStyle(
                                  fontFamily: 'PingFang',
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: AdaptationUtils.adaptWidth(14)),
                            ),
                          ),
                          // 地点
                          Container(
                            padding: EdgeInsets.only(
                                left: AdaptationUtils.adaptWidth(16),
                                right: AdaptationUtils.adaptWidth(16),
                                bottom: AdaptationUtils.adaptHeight(4)),
                            child: Text(
                              info.geo.reverse,
                              style: TextStyle(
                                  fontFamily: 'PingFang',
                                  shadows: const [
                                    const Shadow(
                                        color: Color(0x88000000),
                                        offset: Offset(2, 2),
                                        blurRadius: 4)
                                  ],
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: AdaptationUtils.adaptWidth(12)),
                            ),
                          ),
                          //月份 星期 特别日子
                          Container(
                            margin: EdgeInsets.only(
                                left: AdaptationUtils.adaptWidth(16),
                                right: AdaptationUtils.adaptWidth(16),
                                bottom: AdaptationUtils.adaptWidth(28)),
                            child: Text(
                              '${MONTHS[info.getDateTime().month - 1]}.${WEEKS[info.getDateTime().weekday - 1]}' +
                                  (info.event == null ? '' : ',${info.event}'),
                              style: TextStyle(
                                  fontFamily: 'PingFang',
                                  shadows: const [
                                    const Shadow(
                                        color: Color(0x88000000),
                                        offset: Offset(2, 2),
                                        blurRadius: 4)
                                  ],
                                  letterSpacing: 1,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: AdaptationUtils.adaptWidth(22)),
                            ),
                          ),
                          // 日期
                          Container(
                            height: AdaptationUtils.adaptHeight(130),
                            margin: EdgeInsets.only(
                                left: AdaptationUtils.adaptWidth(16),
                                right: AdaptationUtils.adaptWidth(16),
                                bottom: AdaptationUtils.adaptHeight(5)),
                            child: Text(
                              info.dateKey.substring(6),
                              style: TextStyle(
                                  shadows: const [
                                    const Shadow(
                                        color: Color(0x88000000),
                                        offset: Offset(2, 2),
                                        blurRadius: 4)
                                  ],
                                  fontFamily: 'PingFang',
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                  fontSize: AdaptationUtils.adaptWidth(120)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: shouldHideItems() ? 0 : (1 - opacityLevel),
                      child: GestureDetector(
                        onTap: (1 - opacityLevel) == 0
                            ? null
                            : () async {
                                String uri =InfoModel.realImagePath(
                                    AdaptationUtils.safeAreaBottom > 0
                                        ? info.images['iphone-x']
                                        : info.images['big568h2x']);
                                ByteData bytes = await NetworkAssetBundle(Uri.base.resolve(uri)).load(uri);
                                // TODO 保存

                              },
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: AdaptationUtils.safeAreaBottom + 40),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset('assets/icons/save.png',
                                width: AdaptationUtils.adaptWidth(60),
                                height: AdaptationUtils.adaptHeight(60)),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

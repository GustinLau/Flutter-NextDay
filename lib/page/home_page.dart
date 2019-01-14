import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:next_day/component/day_component.dart';
import 'package:next_day/constant/api.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/service/cache_service.dart';
import 'package:next_day/service/http_service.dart';

class HomePage extends StatefulWidget {
  HomePage() : super();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, InfoModel> _dayInfoMap = new Map();
  bool canScroll = true;
  bool isScrolling = false;

  _HomePageState() : super() {
    _getInfoWithOffset(0);
  }

  String _keyWithOffset(int offset){
    DateTime date = DateTime(2019,1,11).add(Duration(days: -offset));
   return '${date.year}'
        '${date.month < 10 ? '0${date.month.toString()}' : date.month}'
        '${date.day < 10 ? '0${date.day.toString()}' : date.day}';
  }

  void _getInfoWithOffset(int offset, [bool stop = false]) async {
    String key = _keyWithOffset(offset);
    var cachedDayInfoStr = await CacheService.get(key);
    if (cachedDayInfoStr == null) {
      // 不存在缓存
      String path = API_DAY_INFO;
      path = path
          .replaceAll(new RegExp(r'\{year\}'), key.substring(0, 4))
          .replaceAll(new RegExp(r'\{month\}'), key.substring(4, 6))
          .replaceAll(new RegExp(r'\{day\}'), key.substring(6));
      HttpService httpService = HttpService(
          path: path,
          onSuccess: (data) {
            CacheService.save(key, json.encode(data));
            if (stop) {
              setState(() {
                _dayInfoMap[key] = InfoModel.fromJson(data[key]);
              });
            } else {
              _dayInfoMap[key] = InfoModel.fromJson(data[key]);
            }
          },
          onError: (code) {
            if (stop) {
              setState(() {
                _dayInfoMap[key] = null;
              });
            } else {
              _dayInfoMap[key] = null;
            }
          },
          autoStart: false);
      await httpService.start();
    } else {
      var data = json.decode(cachedDayInfoStr);
      if (stop) {
        setState(() {
          _dayInfoMap[key] = InfoModel.fromJson(data[key]);
        });
      } else {
        _dayInfoMap[key] = InfoModel.fromJson(data[key]);
      }
    }
    if (!stop) {
      _getInfoWithOffset(offset + 1, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Container(
      color: Colors.white,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.runtimeType == ScrollStartNotification) {
            // 开始滑动
            if (!isScrolling) {
              setState(() {
                isScrolling = true;
              });
            }
          }
          if (notification.runtimeType == ScrollEndNotification) {
            // 结束滑动
            if (isScrolling) {
              setState(() {
                isScrolling = false;
              });
            }
          }
        },
        child: PageView.builder(
            controller: PageController(viewportFraction: 1),
            scrollDirection: Axis.horizontal,
            itemCount: _dayInfoMap.length,
            reverse: true,
            physics: canScroll
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (i) {
              if (i == _dayInfoMap.length - 1) {
                _getInfoWithOffset(_dayInfoMap.length);
              }
            },
            itemBuilder: (context, i) {
              return Column(
                children: <Widget>[
                  Expanded(
                      child: DayComponent(
                    info: _dayInfoMap.containsKey(_keyWithOffset(i)) ? _dayInfoMap[_keyWithOffset(i)] : null,
                    onToggleOpacity: (bool status) {
                      setState(() {
                        canScroll = status;
                      });
                    },
                    shouldHideItems: () => isScrolling,
                  )),
                ],
              );
            }),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/constant/api.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/page/setting/setting_page.dart';
import 'package:next_day/plugin/share_plugin.dart';
import 'package:next_day/service/cache_service.dart';
import 'package:next_day/service/http_service.dart';
import 'package:next_day/util/adaptation_utils.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';
import 'package:rxdart/rxdart.dart';

class HomePageBloc extends BlocBase {
  HomePageState _state = HomePageState();
  BehaviorSubject _subject = BehaviorSubject<HomePageState>();

  HomePageBloc() {
    getInfoWithOffset(0);
  }

  ValueObservable<HomePageState> get stream => _subject.stream;

  HomePageState get state => _state;

  /// 根据偏移值计算日期
  String keyWithOffset(int offset) {
    DateTime date = DateTime.now().add(Duration(days: -offset));
    return '${date.year}'
        '${date.month < 10 ? '0${date.month.toString()}' : date.month}'
        '${date.day < 10 ? '0${date.day.toString()}' : date.day}';
  }

  /// 请求数据
  void _getInfoWithOffset(int offset, [bool stop = false]) async {
    String key = keyWithOffset(offset);
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
              _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
              if (_state._currentInfo == null) {
                _state._currentInfo = _state._dayInfoMap[key];
              }
              _subject.add(_state);
            } else {
              _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
              if (_state._currentInfo == null) {
                _state._currentInfo = _state._dayInfoMap[key];
              }
            }
          },
          onError: (code) {
            if (stop) {
              _state._dayInfoMap[key] = null;
              _subject.add(_state);
            } else {
              _state._dayInfoMap[key] = null;
            }
          },
          autoStart: false);
      await httpService.start();
    } else {
      var data = json.decode(cachedDayInfoStr);
      if (stop) {
        _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
        if (_state._currentInfo == null) {
          _state._currentInfo = _state._dayInfoMap[key];
        }
        _subject.add(_state);
      } else {
        _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
        if (_state._currentInfo == null) {
          _state._currentInfo = _state._dayInfoMap[key];
        }
      }
    }
    if (!stop) {
      _getInfoWithOffset(offset + 1, true);
    }
  }

  void getInfoWithOffset(int offset) => _getInfoWithOffset(offset);

  void setGlobalKey(GlobalKey globalKey) => _state._globalKey = globalKey;

  void setScrolling(bool isScrolling) {
    if (isScrolling != _state.isScrolling) {
      _state._isScrolling = isScrolling;
      _subject.add(_state);
    }
  }

  void setCanScroll(bool canScroll) {
    if (canScroll != _state.canScroll) {
      _state._canScroll = canScroll;
      _subject.add(_state);
    }
  }

  void setCurrentInfo(InfoModel info) {
    _state._currentInfo = info;
  }

  void share() async {
    Fluttertoast.showToast(
        msg: '请稍候...',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.black.withAlpha(200),
        textColor: Colors.white);
    RenderRepaintBoundary boundary =
        _state._globalKey.currentContext.findRenderObject();
    ui.Image image =
        await boundary.toImage(pixelRatio: AdaptationUtils.instance.deviceRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    await SharePlugin.share(byteData.buffer.asUint8List());
    MusicPlayerBloc.instance.hide(false);
  }

  void setStartDragPosition(Offset position) {
    if (_state.dragPercent == 1) {
      _state._startDragPosition = Offset(position.dx, position.dy - 200);
    } else if (_state.dragPercent == -1) {
      _state._startDragPosition = Offset(position.dx, position.dy + 200);
    } else {
      _state._startDragPosition = position;
    }
  }

  void setCurrentDragPosition(Offset position) {
    double diff = (position.dy - _state.startDragPosition.dy);
    diff = diff < -200.0 ? -200.0 : diff;
    diff = diff > 200.0 ? 200.0 : diff;
    _state._dragPercent = diff / 200.0;
    _subject.add(_state);
  }

  void setDragDirection(double direction) {
    if (_state._dragType == 0) {
      _state._dragType = direction >= 1 ? 1 : -1;
    }
    if (direction != 0) {
      _state._dragDirection = direction;
    }
  }

  void setDragging(bool dragging) {
    _state._dragging = dragging;
    if (!dragging) {
      if (_state._dragPercent < 0) {
        if (_state._dragDirection > 0) {
          _state._dragPercent = 0;
        } else {
          _state._dragPercent = -1;
        }
        _subject.add(_state);
      }
    }
  }

  void showSetting(BuildContext context) {
    _state._dragPercent = 0;
    _subject.add(_state);
    Navigator.push(
      context,
      PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => SettingPage(),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) =>
                  SlideTransition(
                    position: new Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  )),
    );
  }

  @override
  void dispose() {
    _subject.close();
  }
}

class HomePageState {
  Map<String, InfoModel> _dayInfoMap = new Map();
  InfoModel _currentInfo;
  bool _canScroll = true;
  bool _isScrolling = false;
  GlobalKey _globalKey;

  Offset _startDragPosition;
  double _dragDirection;
  double _dragPercent = 0;

  // -1 向上 0 初始状态 1 向下
  int _dragType = 0;
  bool _dragging = false;

  Map<String, InfoModel> get dayInfoMap => _dayInfoMap;

  InfoModel get currentInfo => _currentInfo;

  bool get canScroll => _canScroll;

  bool get isScrolling => _isScrolling;

  Offset get startDragPosition => _startDragPosition;

  int get dragType => _dragType;

  bool get dragging => _dragging;

  double get dragPercent => _dragPercent;

  GlobalKey get globalKey => _globalKey;
}

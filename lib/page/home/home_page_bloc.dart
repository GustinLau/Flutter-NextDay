import 'dart:convert';

import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/constant/api.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/service/cache_service.dart';
import 'package:next_day/service/http_service.dart';
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
              _subject.add(_state);
            } else {
              _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
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
        _subject.add(_state);
      } else {
        _state._dayInfoMap[key] = InfoModel.fromJson(data[key]);
      }
    }
    if (!stop) {
      _getInfoWithOffset(offset + 1, true);
    }
  }

  void getInfoWithOffset(int offset) => _getInfoWithOffset(offset);

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

  @override
  void dispose() {
    _subject.close();
  }
}

class HomePageState {
  Map<String, InfoModel> _dayInfoMap = new Map();
  bool _canScroll = true;
  bool _isScrolling = false;

  Map<String, InfoModel> get dayInfoMap => _dayInfoMap;

  bool get canScroll => _canScroll;

  bool get isScrolling => _isScrolling;
}

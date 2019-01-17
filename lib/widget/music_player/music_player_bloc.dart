import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:next_day/model/info_model.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayerBloc {
  MusicPlayerState _state = MusicPlayerState();
  BehaviorSubject _subject = BehaviorSubject<MusicPlayerState>();
  AudioPlayer _audioPlayer;
  StreamSubscription _onAudioPositionChangedSubscription;
  StreamSubscription _onPlayerStateChangedSubscription;

  static MusicPlayerBloc _instance;

  static MusicPlayerBloc get instance => _getInstance();

  factory MusicPlayerBloc() => _getInstance();

  static MusicPlayerBloc _getInstance() {
    if (_instance == null) {
      _instance = new MusicPlayerBloc._internal();
    }
    return _instance;
  }

  MusicPlayerBloc._internal() {
    // 初始化
  }

  /// 初始化播放器
  void _initPlayer() {
    if (_audioPlayer == null) {
      _audioPlayer = new AudioPlayer();
      _onAudioPositionChangedSubscription =
          _audioPlayer.onAudioPositionChanged.listen((Duration position) {
        double currentProgress = (position.inSeconds * 1.0) /
            (_audioPlayer.duration.inSeconds * 1.0);
        if (currentProgress != state.progress) {
          _state._progress = currentProgress;
          _subject.add(_state);
        }
      });
      _onPlayerStateChangedSubscription =
          _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
        if (state == AudioPlayerState.COMPLETED) {
          stop();
        }
      });
    }
  }

  /// 更新当前页面歌曲信息
  void updateMusic(MusicModel music) {
    _state._currentMusic = music;
    _subject.add(_state);
  }

  /// 是否禁用按钮事件
  void setButtonEnabled(bool enabled) {
    if (_state._enabledButton != enabled) {
      _state._enabledButton = enabled;
      _subject.add(_state);
    }
  }

  /// 播放
  void play() async {
    _initPlayer();
    if (!_state._playing) {
      if (_state._playingMusic != _state._currentMusic) {
        _state._playingMusic = _state._currentMusic;
        _state._progress = 0;
      }
      await _audioPlayer
          .play(InfoModel.realMusicPath(_state._playingMusic.url));
      _state._playing = true;
      _subject.add(_state);
    }
  }

  /// 停止
  void stop() async {
    if (_state._playing) {
      _state._playingMusic = _state._currentMusic;
      await _audioPlayer.stop();
      _state._playing = false;
      _state._progress = 0;
      _subject.add(_state);
    }
  }

  /// 暂停
  void pause() async {
    if (_state._playing) {
      await _audioPlayer.pause();
      _state._playing = false;
      _subject.add(_state);
    }
  }

  /// 判断当前页面歌曲与播放歌曲是否同一首
  bool isSameMusic() => _state.playingMusic == _state.currentMusic;

  void dispose() {
    _onAudioPositionChangedSubscription.cancel();
    _onPlayerStateChangedSubscription.cancel();
    _subject.close();
  }

  ValueObservable<MusicPlayerState> get stream => _subject.stream;

  MusicPlayerState get state => _state;
}

class MusicPlayerState {
  MusicModel _playingMusic;
  MusicModel _currentMusic;
  bool _playing = false;
  double _progress = 0;
  bool _enabledButton = true;

  MusicPlayerState();

  MusicModel get playingMusic => _playingMusic;

  bool get playing => _playing;

  double get progress => _progress;

  MusicModel get currentMusic => _currentMusic;

  bool get enabledButton => _enabledButton;
}

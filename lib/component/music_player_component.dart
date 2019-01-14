import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/util/adaptation_utils.dart';

class MusicPlayerComponent extends StatefulWidget {
  final MusicModel musicModel;
  final ValueGetter<bool> canTogglePlayer;

  MusicPlayerComponent({Key key, this.musicModel, this.canTogglePlayer})
      : super(key: key);

  @override
  State createState() => _MusicPlayerComponentState(
      musicModel: musicModel, canTogglePlayer: canTogglePlayer);
}

class _MusicPlayerComponentState extends State<MusicPlayerComponent> {
  final MusicModel musicModel;
  final ValueGetter<bool> canTogglePlayer;

  bool playing = false;
  bool onAction = false;
  double progress = 0;
  AudioPlayer audioPlayer;
  StreamSubscription onPlayerStateChangedSubscription;

  _MusicPlayerComponentState({this.musicModel, this.canTogglePlayer});

  _initPlayer() {
    if (audioPlayer == null) {
      audioPlayer = new AudioPlayer();
      audioPlayer.onAudioPositionChanged.listen((Duration position) {
        double tmpProgress =
            (position.inSeconds * 1.0) / (audioPlayer.duration.inSeconds * 1.0);
        if (tmpProgress != progress) {
          setState(() {
            progress = tmpProgress;
          });
        }
      });
      onPlayerStateChangedSubscription = audioPlayer.onPlayerStateChanged
          .listen((AudioPlayerState state) async {
        if (state == AudioPlayerState.COMPLETED) {
          setState(() {
            playing = false;
          });
        }
      });
    }
  }

  _toggleMusic() {
    _initPlayer();
    if (!playing) {
      audioPlayer.play(InfoModel.realMusicPath(musicModel.url)).then((void v) {
        onAction = false;
        setState(() {
          playing = true;
        });
      });
    } else {
      audioPlayer.pause().then((void v) {
        onAction = false;
        setState(() {
          playing = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return musicModel == null
        ? Container()
        : Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: !canTogglePlayer()
                          ? null
                          : () {
                              if (!onAction) {
                                onAction = true;
                                _toggleMusic();
                              }
                            },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 0,
                            top: AdaptationUtils.adaptHeight(5) / 2,
                            bottom: AdaptationUtils.adaptHeight(5) / 2,
                            right: AdaptationUtils.adaptWidth(8)),
                        child: Image.asset(
                            'assets/icons/${playing ? 'pause' : 'play'}.png',
                            width: AdaptationUtils.adaptWidth(35),
                            height: AdaptationUtils.adaptHeight(35)),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            musicModel.name,
                            style: TextStyle(
                                shadows: const [
                                  const Shadow(
                                      color: Color(0x88000000),
                                      offset: Offset(2, 2),
                                      blurRadius: 4)
                                ],
                                fontFamily: 'PingFang',
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                fontSize: AdaptationUtils.adaptWidth(14)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            musicModel.artist,
                            style: TextStyle(
                                shadows: const [
                                  const Shadow(
                                      color: Color(0x88000000),
                                      offset: Offset(2, 2),
                                      blurRadius: 4)
                                ],
                                fontFamily: 'PingFang',
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                fontSize: AdaptationUtils.adaptWidth(11)),
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    )
                  ],
                ),
                !playing
                    ? Container()
                    : Container(
                        height: AdaptationUtils.adaptHeight(2),
                        width: AdaptationUtils.screenWidth -
                            AdaptationUtils.adaptWidth(35) * 2,
                        margin: EdgeInsets.only(
                            left: AdaptationUtils.adaptWidth(35),
                            right: AdaptationUtils.adaptWidth(35),
                            bottom: AdaptationUtils.adaptHeight(5)),
                        color: const Color(0xAAFFFFFF),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: (AdaptationUtils.screenWidth -
                                    AdaptationUtils.adaptWidth(35) * 2) *
                                progress,
                            color: Colors.white,
                          ),
                        ),
                      )
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    if (audioPlayer != null) {
      audioPlayer.stop().then((void v) {
        onPlayerStateChangedSubscription.cancel();
        audioPlayer = null;
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/util/adaptation_utils.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';

class MusicPlayer extends StatelessWidget {
  final MusicModel musicModel;

  MusicPlayer({Key key, this.musicModel}) : super(key: key);

  /// 按钮
  Widget _button(MusicPlayerBloc musicPlayerBloc, MusicPlayerState state) {
    return GestureDetector(
      onTap: !state.enabledButton
          ? null
          : () {
              if (state.playing) {
                if (musicPlayerBloc.isSameMusic()) {
                  musicPlayerBloc.pause();
                } else {
                  musicPlayerBloc.stop();
                }
              } else {
                musicPlayerBloc.play();
              }
            },
      child: Padding(
        padding: EdgeInsets.only(
            left: 0,
            top: AdaptationUtils.adaptHeight(5) / 2,
            bottom: AdaptationUtils.adaptHeight(5) / 2,
            right: AdaptationUtils.adaptWidth(8)),
        child: Image.asset(
            'assets/icons/${state.playing ? (musicPlayerBloc.isSameMusic()?'pause':'stop') : 'play'}.png',
            width: AdaptationUtils.adaptWidth(35),
            height: AdaptationUtils.adaptHeight(35)),
      ),
    );
  }

  /// 歌曲信息
  Widget _musicInfo(MusicPlayerBloc musicPlayerBloc, MusicPlayerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(state.playing ? state.playingMusic.name : state.currentMusic.name,
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
            overflow: TextOverflow.ellipsis),
        Text(
          state.playing ? state.playingMusic.artist : state.currentMusic.artist,
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
    );
  }

  /// 播放进度条
  Widget _progressBar(MusicPlayerBloc musicPlayerBloc, MusicPlayerState state) {
    return !state.playing
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
                    state.progress,
                color: Colors.white,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    MusicPlayerBloc musicPlayerBloc = MusicPlayerBloc.instance;
    if (musicPlayerBloc.state.currentMusic == null) {
      musicPlayerBloc.updateMusic(musicModel);
    }
    return StreamBuilder<MusicPlayerState>(
        stream: musicPlayerBloc.stream,
        initialData: musicPlayerBloc.state,
        builder:
            (BuildContext context, AsyncSnapshot<MusicPlayerState> snapshot) {
          MusicPlayerState state = snapshot.data;
          return !state.playing && (state.currentMusic == null)
              ? Container()
              : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _button(musicPlayerBloc, state),
                          Expanded(
                            child: _musicInfo(musicPlayerBloc, state),
                          )
                        ],
                      ),
                      _progressBar(musicPlayerBloc, state)
                    ],
                  ),
                );
        });
  }
}

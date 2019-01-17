import 'package:next_day/base/bloc_base.dart';
import 'package:next_day/page/home/home_page_bloc.dart';
import 'package:next_day/model/info_model.dart';
import 'package:next_day/widget/music_player/music_player_bloc.dart';
import 'package:rxdart/rxdart.dart';

class DayBloc extends BlocBase {
  DayState _state = DayState();
  BehaviorSubject _subject = BehaviorSubject<DayState>();
  HomePageBloc _homePageBloc;

  DayBloc({homePageBloc, info}) {
    _homePageBloc = homePageBloc;
    _state._info = info;
    _state._showMainView = homePageBloc.state.canScroll;
    _state._hideAllView = homePageBloc.state.isScrolling;
    if (_state.hideAllView || !_state._showMainView) {
      MusicPlayerBloc.instance.setButtonEnabled(false);
    } else {
      MusicPlayerBloc.instance.setButtonEnabled(true);
    }
    _subject.add(_state);
  }

  void toggleView() =>
      _homePageBloc.setCanScroll(!_homePageBloc.state.canScroll);

  ValueObservable<DayState> get stream => _subject.stream;

  DayState get state => _state;

  @override
  void dispose() {
    _subject.close();
  }
}

class DayState {
  InfoModel _info;
  bool _showMainView;
  bool _hideAllView;

  bool get hideAllView => _hideAllView;

  bool get showMainView => _showMainView;

  InfoModel get info => _info;
}

enum MyEventsEnum {
  setMedia,
  setMute,
  setLyricPosition,
  setLyric,
  setVisible,
  setError,
  setPlayerState
}

class MyEvents {
  final Map<MyEventsEnum, List<Function>> _events = {};
  void on(MyEventsEnum event, Function listener) {
    if (_events[event] != null) {
      _events[event]!.add(listener);
    } else {
      _events.putIfAbsent(event, () => [listener]);
    }
  }

  void off(MyEventsEnum event, Function listener) {
    var ar = _events[event];
    if (ar != null) {
      ar.remove(listener);
    }
  }

  void emit(MyEventsEnum event, arg) {
    var ar = _events[event];
    if (ar != null) {
      for (var func in ar) {
        func(arg);
      }
    }
  }
}

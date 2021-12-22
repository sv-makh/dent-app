import 'dart:async';

final appBloc = AppPropertiesBloc();

class AppPropertiesBloc{
  StreamController<String> _title = StreamController<String>();
  StreamController<String> _titleButton = StreamController<String>();

  Stream<String> get titleStream => _title.stream;
  Stream<String> get titleButtonStream => _titleButton.stream;

  updateTitle(String newTitle){
    _title.sink.add(newTitle);
  }

  updateTitleButton(String newTitleButton) {
    _titleButton.sink.add(newTitleButton);
  }

  dispose() {
    _title.close();
    _titleButton.close();
  }
}
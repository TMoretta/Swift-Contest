import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configureUrlStrategy() {
  setUrlStrategy(NoHistoryUrlStrategy());
}

class NoHistoryUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object? state, String title, String url) {
    replaceState(state, title, url);
  }
}
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configureUrlStrategy() {
  setUrlStrategy(NoHistoryUrlStrategy());
}

class NoHistoryUrlStrategy extends PathUrlStrategy {
  NoHistoryUrlStrategy([super.platformLocation])
      : _basePath = stripTrailingSlash(extractPathname(checkBaseHref(
    platformLocation.getBaseHref(),
  )));

  final String _basePath;

  @override
  String prepareExternalUrl(String internalUrl) {
    if (internalUrl.isNotEmpty && !internalUrl.startsWith('/')) {
      internalUrl = '/$internalUrl';
    }
    return '$_basePath/';
  }

  @override
  void pushState(Object? state, String title, String url) {
    replaceState(state, title, url);
  }
}
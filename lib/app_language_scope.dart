import 'package:flutter/widgets.dart';

import 'services/language_preferences.dart';

class AppLanguageScope extends InheritedWidget {
  const AppLanguageScope({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required super.child,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  static AppLanguageScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    assert(scope != null, 'AppLanguageScope was not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppLanguageScope oldWidget) {
    return language != oldWidget.language ||
        onLanguageChanged != oldWidget.onLanguageChanged;
  }
}

import 'package:flutter/widgets.dart';

import 'services/theme_preferences.dart';

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required this.theme,
    required this.onThemeChanged,
    required super.child,
  });

  final AppThemePreference theme;
  final ValueChanged<AppThemePreference> onThemeChanged;

  static AppThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope was not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) {
    return theme != oldWidget.theme ||
        onThemeChanged != oldWidget.onThemeChanged;
  }
}

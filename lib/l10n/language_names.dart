import '../services/language_preferences.dart';
import 'generated/app_localizations.dart';

extension AppLanguageNames on AppLanguage {
  String label(AppLocalizations l10n) {
    return switch (this) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.zh => l10n.languageChinese,
      AppLanguage.en => l10n.languageEnglish,
    };
  }
}

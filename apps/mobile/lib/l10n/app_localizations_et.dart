// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appTitle => 'HealthTrack';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Loobu';

  @override
  String get commonRetry => 'Proovi uuesti';

  @override
  String get signInTitle => 'Logi sisse';

  @override
  String get signInEmailLabel => 'E-post';

  @override
  String get signInPasswordLabel => 'Salasõna';
}

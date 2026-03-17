// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Fred';

  @override
  String get readyToStart => 'Klar til å starte';

  @override
  String get microphoneAccessRequired => 'Mikrofontilgang kreves';

  @override
  String get microphoneAccessDescription =>
      'Denne appen trenger tilgang til mikrofonen for å overvåke støynivå og holde orden på stilletid.';

  @override
  String get grantPermission => 'Gi tilgang';

  @override
  String get microphonePermissionRequired => 'Mikrofontilgang kreves';

  @override
  String get pleaseEnableMicrophoneAccess =>
      'Denne appen trenger tilgang til mikrofonen for å overvåke støynivå.\n\nVennligst aktiver mikrofontilgang i Innstillinger.';

  @override
  String get cancel => 'Avbryt';

  @override
  String get openSettings => 'Åpne innstillinger';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Nullstill';

  @override
  String get timerComplete => 'Bra jobba!';

  @override
  String get restart => 'Start på nytt';

  @override
  String get settings => 'Innstillinger';

  @override
  String get timerDuration => 'Timervarighet';

  @override
  String minutes(int count) {
    return '$count minutter';
  }

  @override
  String get noiseThreshold => 'Støygrense';

  @override
  String get timerResetsWhenExceeded =>
      'Timeren nullstilles når støyen overskrider dette nivået';

  @override
  String get warningThreshold => 'Advarselsgrense';

  @override
  String get warningsStartAtLevel =>
      'Visuelle og haptiske advarsler starter på dette nivået';

  @override
  String get decibelReference => 'Desibel-referanse';

  @override
  String get whisper => 'Hvisking';

  @override
  String get quietLibrary => 'Stille bibliotek';

  @override
  String get normalConversation => 'Normal samtale';

  @override
  String get busyTraffic => 'Travle gater';

  @override
  String get alarmClock => 'Vekkerklokke';

  @override
  String get language => 'Språk';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get english => 'Engelsk';

  @override
  String get norwegian => 'Norsk';
}

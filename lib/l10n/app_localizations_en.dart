// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fred';

  @override
  String get readyToStart => 'Ready to start';

  @override
  String get microphoneAccessRequired => 'Microphone Access Required';

  @override
  String get microphoneAccessDescription =>
      'This app needs microphone access to monitor noise levels and keep track of quiet time.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get microphonePermissionRequired => 'Microphone Permission Required';

  @override
  String get pleaseEnableMicrophoneAccess =>
      'This app needs microphone access to monitor noise levels.\n\nPlease enable microphone access in Settings.';

  @override
  String get cancel => 'Cancel';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Reset';

  @override
  String get timerComplete => 'Timer Complete!';

  @override
  String get restart => 'Restart';

  @override
  String get settings => 'Settings';

  @override
  String get timerDuration => 'Timer Duration';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String get noiseThreshold => 'Noise Threshold';

  @override
  String get timerResetsWhenExceeded =>
      'Timer resets when noise exceeds this level';

  @override
  String get warningThreshold => 'Warning Threshold';

  @override
  String get warningsStartAtLevel =>
      'Visual and haptic warnings start at this level';

  @override
  String get decibelReference => 'Decibel Reference';

  @override
  String get whisper => 'Whisper';

  @override
  String get quietLibrary => 'Quiet library';

  @override
  String get normalConversation => 'Normal conversation';

  @override
  String get busyTraffic => 'Busy traffic';

  @override
  String get alarmClock => 'Alarm clock';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get english => 'English';

  @override
  String get norwegian => 'Norwegian';
}

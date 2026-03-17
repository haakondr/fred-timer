import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Fred'**
  String get appTitle;

  /// Text shown when timer is not running
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get readyToStart;

  /// Title for microphone permission screen
  ///
  /// In en, this message translates to:
  /// **'Microphone Access Required'**
  String get microphoneAccessRequired;

  /// Description of why microphone access is needed
  ///
  /// In en, this message translates to:
  /// **'This app needs microphone access to monitor noise levels and keep track of quiet time.'**
  String get microphoneAccessDescription;

  /// Button to grant microphone permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Dialog title for permission settings
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission Required'**
  String get microphonePermissionRequired;

  /// Dialog message for opening settings
  ///
  /// In en, this message translates to:
  /// **'This app needs microphone access to monitor noise levels.\n\nPlease enable microphone access in Settings.'**
  String get pleaseEnableMicrophoneAccess;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Timer completion message
  ///
  /// In en, this message translates to:
  /// **'Timer Complete!'**
  String get timerComplete;

  /// Button to restart after completion
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Timer duration setting label
  ///
  /// In en, this message translates to:
  /// **'Timer Duration'**
  String get timerDuration;

  /// Minutes label with count
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// Noise threshold setting label
  ///
  /// In en, this message translates to:
  /// **'Noise Threshold'**
  String get noiseThreshold;

  /// Noise threshold description
  ///
  /// In en, this message translates to:
  /// **'Timer resets when noise exceeds this level'**
  String get timerResetsWhenExceeded;

  /// Warning threshold setting label
  ///
  /// In en, this message translates to:
  /// **'Warning Threshold'**
  String get warningThreshold;

  /// Warning threshold description
  ///
  /// In en, this message translates to:
  /// **'Visual and haptic warnings start at this level'**
  String get warningsStartAtLevel;

  /// Decibel reference card title
  ///
  /// In en, this message translates to:
  /// **'Decibel Reference'**
  String get decibelReference;

  /// 30 dB reference
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get whisper;

  /// 40 dB reference
  ///
  /// In en, this message translates to:
  /// **'Quiet library'**
  String get quietLibrary;

  /// 60 dB reference
  ///
  /// In en, this message translates to:
  /// **'Normal conversation'**
  String get normalConversation;

  /// 70 dB reference
  ///
  /// In en, this message translates to:
  /// **'Busy traffic'**
  String get busyTraffic;

  /// 80 dB reference
  ///
  /// In en, this message translates to:
  /// **'Alarm clock'**
  String get alarmClock;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Norwegian language option
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get norwegian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

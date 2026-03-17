import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final int timerDurationMinutes;
  final double decibelThreshold;
  final double warningThreshold;
  final String? languageCode; // null = use system default

  AppSettings({
    this.timerDurationMinutes = 10,
    this.decibelThreshold = 80.0,
    this.warningThreshold = 75.0,
    this.languageCode,
  });

  factory AppSettings.fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      timerDurationMinutes: prefs.getInt('timerDurationMinutes') ?? 10,
      decibelThreshold: prefs.getDouble('decibelThreshold') ?? 80.0,
      warningThreshold: prefs.getDouble('warningThreshold') ?? 75.0,
      languageCode: prefs.getString('languageCode'),
    );
  }

  Future<void> saveToPreferences(SharedPreferences prefs) async {
    await prefs.setInt('timerDurationMinutes', timerDurationMinutes);
    await prefs.setDouble('decibelThreshold', decibelThreshold);
    await prefs.setDouble('warningThreshold', warningThreshold);
    if (languageCode != null) {
      await prefs.setString('languageCode', languageCode!);
    } else {
      await prefs.remove('languageCode');
    }
  }

  AppSettings copyWith({
    int? timerDurationMinutes,
    double? decibelThreshold,
    double? warningThreshold,
    String? languageCode,
    bool clearLanguageCode = false,
  }) {
    return AppSettings(
      timerDurationMinutes: timerDurationMinutes ?? this.timerDurationMinutes,
      decibelThreshold: decibelThreshold ?? this.decibelThreshold,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      languageCode: clearLanguageCode ? null : (languageCode ?? this.languageCode),
    );
  }
}

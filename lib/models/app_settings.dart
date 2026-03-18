import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final int timerDurationMinutes;
  final double decibelThreshold;
  final double warningThreshold;

  AppSettings({
    this.timerDurationMinutes = 10,
    this.decibelThreshold = 90.0,
    this.warningThreshold = 80.0,
  });

  factory AppSettings.fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      timerDurationMinutes: prefs.getInt('timerDurationMinutes') ?? 10,
      decibelThreshold: prefs.getDouble('decibelThreshold') ?? 90.0,
      warningThreshold: prefs.getDouble('warningThreshold') ?? 80.0,
    );
  }

  Future<void> saveToPreferences(SharedPreferences prefs) async {
    await prefs.setInt('timerDurationMinutes', timerDurationMinutes);
    await prefs.setDouble('decibelThreshold', decibelThreshold);
    await prefs.setDouble('warningThreshold', warningThreshold);
  }
}

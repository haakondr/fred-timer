import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final int timerDurationMinutes;
  final double noiseThreshold;

  AppSettings({
    this.timerDurationMinutes = 10,
    this.noiseThreshold = 85.0,
  });

  /// Warning threshold is always 85% of the noise threshold
  double get warningThreshold => noiseThreshold * 0.85;

  factory AppSettings.fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      timerDurationMinutes: prefs.getInt('timerDurationMinutes') ?? 10,
      noiseThreshold: prefs.getDouble('decibelThreshold') ?? 85.0,
    );
  }

  Future<void> saveToPreferences(SharedPreferences prefs) async {
    await prefs.setInt('timerDurationMinutes', timerDurationMinutes);
    await prefs.setDouble('decibelThreshold', noiseThreshold);
  }

  AppSettings copyWith({
    int? timerDurationMinutes,
    double? noiseThreshold,
  }) {
    return AppSettings(
      timerDurationMinutes: timerDurationMinutes ?? this.timerDurationMinutes,
      noiseThreshold: noiseThreshold ?? this.noiseThreshold,
    );
  }
}

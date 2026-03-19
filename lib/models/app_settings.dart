import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final int timerDurationMinutes;
  final double noiseThreshold;
  final bool hideThresholdButtons;

  AppSettings({
    this.timerDurationMinutes = 10,
    this.noiseThreshold = 85.0,
    this.hideThresholdButtons = false,
  });

  /// Warning threshold is always 95% of the noise threshold
  double get warningThreshold => noiseThreshold * 0.95;

  factory AppSettings.fromPreferences(SharedPreferences prefs) {
    return AppSettings(
      timerDurationMinutes: prefs.getInt('timerDurationMinutes') ?? 10,
      noiseThreshold: prefs.getDouble('decibelThreshold') ?? 85.0,
      hideThresholdButtons: prefs.getBool('hideThresholdButtons') ?? false,
    );
  }

  Future<void> saveToPreferences(SharedPreferences prefs) async {
    await prefs.setInt('timerDurationMinutes', timerDurationMinutes);
    await prefs.setDouble('decibelThreshold', noiseThreshold);
    await prefs.setBool('hideThresholdButtons', hideThresholdButtons);
  }

  AppSettings copyWith({
    int? timerDurationMinutes,
    double? noiseThreshold,
    bool? hideThresholdButtons,
  }) {
    return AppSettings(
      timerDurationMinutes: timerDurationMinutes ?? this.timerDurationMinutes,
      noiseThreshold: noiseThreshold ?? this.noiseThreshold,
      hideThresholdButtons: hideThresholdButtons ?? this.hideThresholdButtons,
    );
  }
}

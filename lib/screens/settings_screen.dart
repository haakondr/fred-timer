import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../strings.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;

  const SettingsScreen({
    super.key,
    required this.settings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _timerDuration;
  late double _decibelThreshold;
  late double _warningThreshold;

  @override
  void initState() {
    super.initState();
    _timerDuration = widget.settings.timerDurationMinutes;
    _decibelThreshold = widget.settings.decibelThreshold;
    _warningThreshold = widget.settings.warningThreshold;
  }

  Future<void> _saveSettingsWithoutPop() async {
    final prefs = await SharedPreferences.getInstance();
    final newSettings = AppSettings(
      timerDurationMinutes: _timerDuration,
      decibelThreshold: _decibelThreshold,
      warningThreshold: _warningThreshold,
    );
    await newSettings.saveToPreferences(prefs);
  }

  Future<void> _saveSettings() async {
    await _saveSettingsWithoutPop();
    if (mounted) {
      final newSettings = AppSettings(
        timerDurationMinutes: _timerDuration,
        decibelThreshold: _decibelThreshold,
        warningThreshold: _warningThreshold,
      );
      Navigator.pop(context, newSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _saveSettings();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF6E3),
        appBar: AppBar(
          title: const Text(Strings.settings),
          foregroundColor: const Color(0xFF073642),
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: const Color(0xFF073642),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveSettings();
            },
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.timerDuration,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.minutes(_timerDuration),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Slider(
                    value: _timerDuration.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$_timerDuration min',
                    onChanged: (value) {
                      setState(() {
                        _timerDuration = value.round();
                      });
                    },
                    onChangeEnd: (value) async {
                      await _saveSettingsWithoutPop();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.noiseThreshold,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_decibelThreshold.round()} dB',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Slider(
                    value: _decibelThreshold,
                    min: 40,
                    max: 100,
                    divisions: 60,
                    label: '${_decibelThreshold.round()} dB',
                    onChanged: (value) {
                      setState(() {
                        _decibelThreshold = value;
                        if (_warningThreshold > _decibelThreshold - 5) {
                          _warningThreshold = _decibelThreshold - 5;
                        }
                      });
                    },
                    onChangeEnd: (value) async {
                      await _saveSettingsWithoutPop();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.timerResetsWhenExceeded,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.warningThreshold,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_warningThreshold.round()} dB',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Slider(
                    value: _warningThreshold,
                    min: 30,
                    max: _decibelThreshold - 5,
                    divisions: (_decibelThreshold - 35).round(),
                    label: '${_warningThreshold.round()} dB',
                    onChanged: (value) {
                      setState(() {
                        _warningThreshold = value;
                      });
                    },
                    onChangeEnd: (value) async {
                      await _saveSettingsWithoutPop();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Strings.warningsStartAtLevel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.violet.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.violet),
                      const SizedBox(width: 8),
                      Text(
                        Strings.decibelReference,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('30 dB - ${Strings.whisper}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('40 dB - ${Strings.quietLibrary}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('60 dB - ${Strings.normalConversation}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('70 dB - ${Strings.busyTraffic}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('80 dB - ${Strings.alarmClock}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/privacy-policy');
            },
            icon: const Icon(Icons.shield_outlined, color: AppColors.violet),
            label: const Text(
              Strings.privacyPolicy,
              style: TextStyle(
                color: AppColors.violet,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ].map((child) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child,
          ),
        )).toList(),
      ),
      ),
    );
  }
}

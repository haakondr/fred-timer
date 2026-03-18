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

  Widget _buildStepper({
    required String label,
    required String value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    String? description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrease $label',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                    foregroundColor: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                  tooltip: 'Increase $label',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                    foregroundColor: AppColors.navy,
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
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
          _buildStepper(
            label: Strings.timerDuration,
            value: Strings.minutes(_timerDuration),
            onDecrement: () {
              if (_timerDuration > 1) {
                setState(() { _timerDuration--; });
                _saveSettingsWithoutPop();
              }
            },
            onIncrement: () {
              if (_timerDuration < 60) {
                setState(() { _timerDuration++; });
                _saveSettingsWithoutPop();
              }
            },
          ),
          const SizedBox(height: 16),
          _buildStepper(
            label: Strings.noiseThreshold,
            value: '${_decibelThreshold.round()} dB',
            description: Strings.timerResetsWhenExceeded,
            onDecrement: () {
              if (_decibelThreshold > 40) {
                setState(() {
                  _decibelThreshold--;
                  if (_warningThreshold > _decibelThreshold - 5) {
                    _warningThreshold = _decibelThreshold - 5;
                  }
                });
                _saveSettingsWithoutPop();
              }
            },
            onIncrement: () {
              if (_decibelThreshold < 100) {
                setState(() { _decibelThreshold++; });
                _saveSettingsWithoutPop();
              }
            },
          ),
          const SizedBox(height: 16),
          _buildStepper(
            label: Strings.warningThreshold,
            value: '${_warningThreshold.round()} dB',
            description: Strings.warningsStartAtLevel,
            onDecrement: () {
              if (_warningThreshold > 30) {
                setState(() { _warningThreshold--; });
                _saveSettingsWithoutPop();
              }
            },
            onIncrement: () {
              if (_warningThreshold < _decibelThreshold - 5) {
                setState(() { _warningThreshold++; });
                _saveSettingsWithoutPop();
              }
            },
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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
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
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/accessibility');
              },
              icon: const Icon(Icons.accessibility_new, color: AppColors.violet),
              label: const Text(
                Strings.accessibility,
                style: TextStyle(
                  color: AppColors.violet,
                  fontSize: 16,
                ),
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

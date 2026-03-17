import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final Function(String?)? onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.settings,
    this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _timerDuration;
  late double _decibelThreshold;
  late double _warningThreshold;
  late String? _languageCode;

  @override
  void initState() {
    super.initState();
    _timerDuration = widget.settings.timerDurationMinutes;
    _decibelThreshold = widget.settings.decibelThreshold;
    _warningThreshold = widget.settings.warningThreshold;
    _languageCode = widget.settings.languageCode;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newSettings = AppSettings(
      timerDurationMinutes: _timerDuration,
      decibelThreshold: _decibelThreshold,
      warningThreshold: _warningThreshold,
      languageCode: _languageCode,
    );
    await newSettings.saveToPreferences(prefs);
    if (mounted) {
      Navigator.pop(context, newSettings);
    }
  }

  String _getLanguageName(BuildContext context, String? code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'en':
        return l10n.english;
      case 'nb':
        return l10n.norwegian;
      default:
        return l10n.systemDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3), // Solarized base3 (cream)
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
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
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String?>(
                    segments: [
                      ButtonSegment<String?>(
                        value: null,
                        label: Text(l10n.systemDefault),
                      ),
                      ButtonSegment<String?>(
                        value: 'en',
                        label: Text(l10n.english),
                      ),
                      ButtonSegment<String?>(
                        value: 'nb',
                        label: Text(l10n.norwegian),
                      ),
                    ],
                    selected: {_languageCode},
                    onSelectionChanged: (Set<String?> newSelection) {
                      setState(() {
                        _languageCode = newSelection.first;
                      });
                      // Immediately apply language change
                      widget.onLanguageChanged?.call(_languageCode);
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
                    l10n.timerDuration,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.minutes(_timerDuration),
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
                    l10n.noiseThreshold,
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.timerResetsWhenExceeded,
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
                    l10n.warningThreshold,
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.warningsStartAtLevel,
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
                        l10n.decibelReference,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('30 dB - ${l10n.whisper}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('40 dB - ${l10n.quietLibrary}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('60 dB - ${l10n.normalConversation}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('70 dB - ${l10n.busyTraffic}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('80 dB - ${l10n.alarmClock}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../strings.dart';

const _darkColor = Color(0xFF073642);

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
  late bool _hideThresholdButtons;

  @override
  void initState() {
    super.initState();
    _timerDuration = widget.settings.timerDurationMinutes;
    _hideThresholdButtons = widget.settings.hideThresholdButtons;
  }

  Future<void> _saveSettingsWithoutPop() async {
    final prefs = await SharedPreferences.getInstance();
    final newSettings = AppSettings(
      timerDurationMinutes: _timerDuration,
      noiseThreshold: widget.settings.noiseThreshold,
      hideThresholdButtons: _hideThresholdButtons,
    );
    await newSettings.saveToPreferences(prefs);
  }

  Future<void> _saveSettings() async {
    await _saveSettingsWithoutPop();
    if (mounted) {
      final newSettings = AppSettings(
        timerDurationMinutes: _timerDuration,
        noiseThreshold: widget.settings.noiseThreshold,
        hideThresholdButtons: _hideThresholdButtons,
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
          foregroundColor: _darkColor,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: _darkColor,
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: _timerDuration > 1 ? () {
                          setState(() { _timerDuration--; });
                          _saveSettingsWithoutPop();
                        } : null,
                        icon: const Icon(Icons.remove),
                        tooltip: 'Decrease ${Strings.timerDuration}',
                        style: IconButton.styleFrom(
                          backgroundColor: _darkColor.withValues(alpha: 0.1),
                          foregroundColor: _darkColor,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        Strings.minutes(_timerDuration),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 24),
                      IconButton.filled(
                        onPressed: _timerDuration < 60 ? () {
                          setState(() { _timerDuration++; });
                          _saveSettingsWithoutPop();
                        } : null,
                        icon: const Icon(Icons.add),
                        tooltip: 'Increase ${Strings.timerDuration}',
                        style: IconButton.styleFrom(
                          backgroundColor: _darkColor.withValues(alpha: 0.1),
                          foregroundColor: _darkColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: Text(
                Strings.hideThresholdButtons,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              value: _hideThresholdButtons,
              activeColor: _darkColor,
              onChanged: (value) {
                setState(() { _hideThresholdButtons = value; });
                _saveSettingsWithoutPop();
              },
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/privacy-policy');
              },
              icon: const Icon(Icons.shield_outlined, color: _darkColor),
              label: const Text(
                Strings.privacyPolicy,
                style: TextStyle(
                  color: _darkColor,
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
              icon: const Icon(Icons.accessibility_new, color: _darkColor),
              label: const Text(
                Strings.accessibility,
                style: TextStyle(
                  color: _darkColor,
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

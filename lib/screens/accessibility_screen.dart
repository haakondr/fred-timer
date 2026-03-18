import 'package:flutter/material.dart';
import '../strings.dart';
import '../theme/app_colors.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        title: const Text(Strings.accessibility),
        foregroundColor: const Color(0xFF073642),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          color: const Color(0xFF073642),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSection(
              context,
              icon: Icons.visibility,
              title: 'Visual Feedback',
              description:
                  'Fred uses multiple visual cues to communicate noise levels:',
              bullets: [
                'Color-coded meter with distinct yellow, coral, and fuchsia zones',
                'Background color changes when noise is too loud',
                'Large, high-contrast countdown timer (72pt)',
                'Timer text color shifts from dark to fuchsia as noise increases',
              ],
            ),
            _buildSection(
              context,
              icon: Icons.vibration,
              title: 'Haptic Feedback',
              description:
                  'Vibration patterns provide non-visual feedback:',
              bullets: [
                'Light pulse every second when noise enters the warning zone',
                'Triple heavy vibration burst when the timer resets',
                'Celebration vibration when the timer completes',
              ],
            ),
            _buildSection(
              context,
              icon: Icons.accessibility_new,
              title: 'Screen Reader Support',
              description:
                  'Fred works with VoiceOver (iOS) and TalkBack (Android):',
              bullets: [
                'Timer countdown is announced as a live region',
                'Noise meter level and status are described semantically',
                'All buttons and controls have accessible labels',
              ],
            ),
            _buildSection(
              context,
              icon: Icons.text_fields,
              title: 'Text & Display',
              description:
                  'Fred respects your system accessibility settings:',
              bullets: [
                'Supports Dynamic Type / system font scaling',
                'High contrast color choices throughout',
                'No information conveyed by color alone — meter uses position and labels',
              ],
            ),
            _buildSection(
              context,
              icon: Icons.phonelink_lock,
              title: 'Screen & Focus',
              description:
                  'The screen stays on while the timer runs so you never lose sight of the countdown. All interactive elements are reachable via keyboard and switch control.',
            ),
            const SizedBox(height: 32),
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    List<String>? bullets,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.violet, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets.map((bullet) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('- ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(bullet, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

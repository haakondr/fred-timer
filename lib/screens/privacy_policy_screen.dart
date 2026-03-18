import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../strings.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        title: const Text(Strings.privacyPolicy),
      ),
      body: SelectionArea(
        child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Privacy Policy for Fred Timer',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Updated: March 17, 2026',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.navy.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            icon: Icons.shield_outlined,
            title: 'Data Collection',
            description: 'We collect NO personal data.',
            bullets: [
              'No account required',
              'No analytics or tracking',
              'No advertisements',
              'No third-party services',
              'No personal information collected',
            ],
          ),
          _buildSection(
            context,
            icon: Icons.mic_none,
            title: 'Microphone Usage',
            description:
                'Fred requires microphone access to measure ambient noise levels for its core functionality.',
            bullets: [
              'Audio is processed in real-time on your device only',
              'No audio is recorded, saved, or transmitted',
              'Audio data is never sent to external servers',
              'Microphone is only active when the timer is running',
            ],
          ),
          _buildSection(
            context,
            icon: Icons.phone_android,
            title: 'Local Data Storage',
            description:
                'Fred stores only the following settings locally on your device: timer duration, noise threshold settings, and language preference.',
            bullets: [
              'Data remains on your device only',
              'Data is not transmitted anywhere',
              'Can be deleted by uninstalling the app',
            ],
          ),
_buildSection(
            context,
            icon: Icons.lock_outline,
            title: 'Data Security',
            description:
                'Since Fred collects no personal data and operates entirely offline, there is no data to secure or transmit. All processing occurs locally on your device.',
          ),
          _buildSection(
            context,
            icon: Icons.email_outlined,
            title: 'Contact',
            description: 'For questions about this privacy policy:',
            linkText: 'Open an issue on GitHub',
            linkUrl: 'https://github.com/haakondr/fred-timer/issues/new',
          ),
          _buildSection(
            context,
            icon: Icons.code,
            title: 'Open Source',
            description: 'Fred is open source software, licensed under the MIT license.',
            linkText: 'github.com/haakondr/fred-timer',
            linkUrl: 'https://github.com/haakondr/fred-timer/',
          ),
          const SizedBox(height: 16),
          Text(
            'Fred is a privacy-first app that operates entirely offline, collects no personal information, and uses your microphone only for real-time noise measurement while the timer runs.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.navy.withValues(alpha: 0.7),
                ),
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
    String? linkText,
    String? linkUrl,
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
          if (linkText != null && linkUrl != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(linkUrl)),
              child: Text(
                linkText,
                style: const TextStyle(
                  color: AppColors.violet,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
            icon: Icons.shield_outlined,
            title: 'Data Collection',
            description: 'We collect NO personal data.',
            bullets: [
              'No account required',
              'No analytics or tracking',
              'No advertisements',
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
            icon: Icons.bug_report_outlined,
            title: 'Error Reporting',
            description:
                'Fred uses Sentry to automatically report crashes and errors. This helps us fix bugs and improve the app. No personal data is included in error reports.',
            bullets: [
              'Error message and stack trace',
              'App version and build number',
              'Device type, OS version, and screen resolution',
              'Breadcrumbs: recent app actions leading up to the error (e.g. navigation, button taps)',
              'No audio data, microphone data, or personal information is sent',
              'Reports are sent to Sentry (sentry.io), a third-party error tracking service',
            ],
          ),
          _buildSection(
            context,
            icon: Icons.lock_outline,
            title: 'Data Security',
            description:
                'Fred collects no personal data. Audio processing occurs entirely on your device. Error reports sent to Sentry contain only technical information needed to diagnose issues.',
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
            'Fred is a privacy-first app that collects no personal information, uses your microphone only for real-time noise measurement while the timer runs, and sends only anonymous error reports to help improve the app.',
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

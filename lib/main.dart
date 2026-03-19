import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'screens/timer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/accessibility_screen.dart';
import 'models/app_settings.dart';
import 'strings.dart';
import 'theme/app_theme.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.sendDefaultPii = false;
        options.attachStacktrace = true;
        options.maxBreadcrumbs = 50;
      },
      appRunner: () => runApp(const QuietTimerApp()),
    );
  } else {
    runApp(const QuietTimerApp());
  }
}

class QuietTimerApp extends StatelessWidget {
  const QuietTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/privacy-policy':
            return MaterialPageRoute(
              builder: (context) => const PrivacyPolicyScreen(),
            );
          case '/accessibility':
            return MaterialPageRoute(
              builder: (context) => const AccessibilityScreen(),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => SettingsScreen(
                settings: AppSettings(),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const MainScreen(),
            );
        }
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings.fromPreferences(prefs);
    setState(() {
      _settings = settings;
    });
  }

  void _navigateToSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          settings: _settings,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _settings = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: Stack(
        children: [
          TimerScreen(settings: _settings),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        Strings.appTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF073642),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: const Color(0xFF073642),
                        tooltip: 'Settings',
                        onPressed: _navigateToSettings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

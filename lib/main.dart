import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/timer_screen.dart';
import 'screens/settings_screen.dart';
import 'models/app_settings.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuietTimerApp());
}

class QuietTimerApp extends StatefulWidget {
  const QuietTimerApp({super.key});

  @override
  State<QuietTimerApp> createState() => _QuietTimerAppState();
}

class _QuietTimerAppState extends State<QuietTimerApp> {
  Locale? _locale;

  void _setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('nb'),
      ],
      locale: _locale,
      localeResolutionCallback: (locale, supportedLocales) {
        // If a specific locale is set, use it
        if (_locale != null) {
          return _locale;
        }

        // Check if system locale is supported
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }

        // Default to English if system locale not supported
        return const Locale('en');
      },
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: MainScreen(onLocaleChanged: _setLocale),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(Locale?) onLocaleChanged;

  const MainScreen({super.key, required this.onLocaleChanged});

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
    _applyLocale(settings);
  }

  void _applyLocale(AppSettings settings) {
    if (settings.languageCode != null) {
      widget.onLocaleChanged(Locale(settings.languageCode!));
    } else {
      widget.onLocaleChanged(null); // Use system default
    }
  }

  void _navigateToSettings() async {
    final result = await Navigator.push<AppSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(settings: _settings),
      ),
    );
    if (result != null) {
      setState(() {
        _settings = result;
      });
      _applyLocale(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: TimerScreen(settings: _settings),
    );
  }
}

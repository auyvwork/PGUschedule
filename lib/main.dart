import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:schedule/screens/schedule_screen.dart';
import 'package:schedule/settings/app_theme.dart';
import 'package:schedule/settings/language.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const String _languageKey = 'app_language_code';
const String _themeKey = 'app_theme_mode';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await initializeDateFormatting('en', null);
  Intl.defaultLocale = 'ru';

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ru');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);
    ThemeMode theme = ThemeMode.system;
    if (savedTheme != null) {
      if (savedTheme == ThemeMode.light.name) {
        theme = ThemeMode.light;
      } else if (savedTheme == ThemeMode.dark.name) {
        theme = ThemeMode.dark;
      }
    }

    final savedLanguageCode = prefs.getString(_languageKey) ?? 'ru';
    final Locale savedLocale = Locale(savedLanguageCode);

    setState(() {
      _themeMode = theme;
      _locale = savedLocale;
      Intl.defaultLocale = savedLocale.languageCode;
    });
  }

  void setLocale(Locale newLocale) async {
    if (newLocale.languageCode != _locale.languageCode) {
      setState(() {
        _locale = newLocale;
        Intl.defaultLocale = newLocale.languageCode;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
    }
  }

  void setThemeMode(ThemeMode newThemeMode) async {
    if (newThemeMode == _themeMode) return;

    setState(() {
      _themeMode = newThemeMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newThemeMode.name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: getTranslatedString(_locale, 'schedule_title'),
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('ru', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return deviceLocale;
          }
        }
        return supportedLocales.first;
      },
      home: const ScheduleScreen(),
    );
  }
}
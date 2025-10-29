import 'package:flutter/material.dart';
import 'package:schedule/main.dart';
import 'package:schedule/settings/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _urlKey = 'saved_content_url';

class SettingsDrawer extends StatelessWidget {
  final TextEditingController urlController;
  final VoidCallback onUrlChanged;
  final bool isLoading;

  const SettingsDrawer({
    super.key,
    required this.urlController,
    required this.onUrlChanged,
    required this.isLoading,
  });

  void _clearUrlAndReload(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
    urlController.clear();
    onUrlChanged();
    Navigator.pop(context);
  }

  // >>> ИСПРАВЛЕНА ЛОГИКА СОХРАНЕНИЯ URL <<<
  void _saveUrlAndReload(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Сохраняем URL в память
    await prefs.setString(_urlKey, urlController.text.trim());
    // Запускаем колбэк (onUrlChanged), который вызовет _fetchContent
    onUrlChanged();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = MyApp.of(context);
    final locale = appState.locale;
    final themeMode = appState.themeMode;

    void changeLanguage(String code) {
      if (locale.languageCode != code) {
        appState.setLocale(Locale(code));
      }
      Navigator.pop(context);
    }

    void changeTheme(ThemeMode mode) {
      appState.setThemeMode(mode);
      Navigator.pop(context);
    }

    // Удалена старая нерабочая функция changeUrlAndLoad
    // void changeUrlAndLoad() {
    //   onUrlChanged();
    //   Navigator.pop(context);
    // }

    return Drawer(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Text(
              getTranslatedString(locale, 'settings'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.normal),
            ),
          ),

          ExpansionTile(
            title: Text(getTranslatedString(locale, 'language')),
            leading: const Icon(Icons.language),
            initiallyExpanded: false,
            children: [
              RadioListTile<String>(
                title: Text(getTranslatedString(locale, 'ru_name')),
                value: 'ru',
                groupValue: locale.languageCode,
                onChanged: (value) => changeLanguage(value!),
              ),
              RadioListTile<String>(
                title: Text(getTranslatedString(locale, 'en_name')),
                value: 'en',
                groupValue: locale.languageCode,
                onChanged: (value) => changeLanguage(value!),
              ),
            ],
          ),

          ExpansionTile(
            title: Text(getTranslatedString(locale, 'theme')),
            leading: const Icon(Icons.palette_outlined),
            initiallyExpanded: false,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(getTranslatedString(locale, 'theme_light')),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (value) => changeTheme(value!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(getTranslatedString(locale, 'theme_dark')),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (value) => changeTheme(value!),
              ),
              RadioListTile<ThemeMode>(
                title: Text(getTranslatedString(locale, 'theme_system')), // 'Системная'
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (value) => changeTheme(value!),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslatedString(locale, 'url_input_label'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    suffixIcon: isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton(
                      icon: const Icon(Icons.send),
                      // >>> ВЫЗЫВАЕМ НОВУЮ ФУНКЦИЮ СОХРАНЕНИЯ <<<
                      onPressed: urlController.text.isNotEmpty ? () => _saveUrlAndReload(context) : null,
                    ),
                  ),
                  // >>> ВЫЗЫВАЕМ НОВУЮ ФУНКЦИЮ СОХРАНЕНИЯ <<<
                  onFieldSubmitted: urlController.text.isNotEmpty ? (_) => _saveUrlAndReload(context) : null,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: Text(getTranslatedString(locale, 'clear_url_button')),
                  onPressed: urlController.text.isNotEmpty ? () => _clearUrlAndReload(context) : null,
                ),
              ],
            ),
          ),

          ExpansionTile(
            title: Text(getTranslatedString(locale, 'about')),
            leading: const Icon(Icons.info_outline),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 16.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslatedString(locale, 'about_title'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(getTranslatedString(locale, 'about_body_p1')),
                    const SizedBox(height: 10),
                    Text(getTranslatedString(locale, 'about_body_p2')),
                    const SizedBox(height: 15),
                    Text(getTranslatedString(locale, 'about_version'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text(getTranslatedString(locale, 'support_text'),
                        style: const TextStyle(fontStyle: FontStyle.italic)),
                    Text(getTranslatedString(locale, 'support_card')),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
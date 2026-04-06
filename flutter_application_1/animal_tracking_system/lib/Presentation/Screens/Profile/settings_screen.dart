import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Controller/app_theme_provider.dart';
import '../../Controller/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'settings'))),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppTranslations.translate(context, 'darkMode')),
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleDarkMode(),
          ),
          ListTile(
            title: Text(AppTranslations.translate(context, 'language')),
            trailing: DropdownButton<String>(
              value: localeProvider.selectedLocale.languageCode,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  localeProvider.setLocale(Locale(value));
                }
              },
            ),
          ),
          ListTile(
            title: Text(AppTranslations.translate(context, 'clearCache')),
            trailing: const Icon(Icons.delete),
            onTap: () {
              // TODO: Clear cache logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache nettoyé')),
              );
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
          ListTile(
            title: const Text('Biométrie'),
            trailing: Switch(value: false, onChanged: (value) {}),
          ),
        ],
      ),
    );
  }
}
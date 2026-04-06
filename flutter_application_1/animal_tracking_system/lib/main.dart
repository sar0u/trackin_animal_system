import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'Config/app_routes.dart';
import 'Core/Network/app_settings_service.dart';
import 'Core/Themes/app_theme.dart';
import 'Presentation/Controller/app_theme_provider.dart';
import 'Presentation/Controller/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettingsService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AppSettingsService>(
      create: (_) => AppSettingsService(),
      child: Builder(
        builder: (context) {
          final settingsService = context.read<AppSettingsService>();

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => AppThemeProvider(settingsService: settingsService),
              ),
              ChangeNotifierProvider(
                create: (_) => LocaleProvider(settingsService: settingsService),
              ),
            ],
            child: Consumer2<AppThemeProvider, LocaleProvider>(
              builder: (context, themeProvider, localeProvider, child) {
                return MaterialApp(
                  title: 'TraceDZ',
                  theme: AppTheme.lightTheme(),
                  darkTheme: AppTheme.darkTheme(),
                  themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                  locale: localeProvider.selectedLocale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('fr'),
                    Locale('ar'),
                  ],
                  initialRoute: AppRoutes.splash,
                  routes: AppRoutes.routes,
                  debugShowCheckedModeBanner: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
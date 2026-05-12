import 'dart:io';

import 'package:cheptel_mobile/presentation/screens/reproduction_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/fermier_provider.dart';
import 'presentation/providers/veterinaire_provider.dart';
import 'presentation/providers/controleur_provider.dart';
import 'presentation/providers/constat_provider.dart';
import 'presentation/providers/movement_provider.dart';
import 'presentation/providers/reproduction_provider.dart';
import 'presentation/providers/health_alert_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/fermier/fermier_home_screen.dart';
import 'presentation/screens/veterinaire/veterinaire_home_screen.dart';
import 'presentation/screens/controleur/controleur_home_screen.dart';
import 'presentation/screens/alerts/health_alert_screen.dart';
import 'presentation/screens/sync/sync_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('fr_FR');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FermierProvider()),
        ChangeNotifierProvider(create: (_) => VeterinaireProvider()),
        ChangeNotifierProvider(create: (_) => ControleurProvider()),
        ChangeNotifierProvider(create: (_) => ConstatProvider()),
        ChangeNotifierProvider(create: (_) => MovementProvider()),
        ChangeNotifierProvider(create: (_) => ReproductionProvider()),
        ChangeNotifierProvider(create: (_) => HealthAlertProvider()),
      ],
      child: const CheptelApp(),
    ),
  );
}

class CheptelApp extends StatelessWidget {
  const CheptelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheptel Trace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5D1E),
          primary: const Color(0xFF0B5D1E),
          secondary: const Color(0xFF063B16),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7FAF5),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2A24),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF1F2A24),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/fermier': (context) => const FermierHomeScreen(),
        '/veterinaire': (context) => const VeterinaireHomeScreen(),
        '/controleur': (context) => const ControleurHomeScreen(),
        '/reproduction': (context) => const ReproductionScreen(),
        '/alerts': (context) => const HealthAlertScreen(),
        '/sync': (context) => const SyncScreen(),
      },
    );
  }
}
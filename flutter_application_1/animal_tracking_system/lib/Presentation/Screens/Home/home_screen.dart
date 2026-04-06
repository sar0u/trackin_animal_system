import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../Animals/animals_list_screen.dart';
import '../Farms/farms_list_screen.dart';
import '../Health/health_history_screen.dart';
import '../Map/map_screen.dart';
import '../Profile/profile_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    AnimalsListScreen(),
    FarmsListScreen(),
    HealthHistoryScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 72,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: AppTranslations.translate(context, 'dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_rounded),
            label: AppTranslations.translate(context, 'animals'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_work_rounded),
            label: AppTranslations.translate(context, 'farms'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.health_and_safety_rounded),
            label: AppTranslations.translate(context, 'health'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_rounded),
            label: AppTranslations.translate(context, 'map'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            label: AppTranslations.translate(context, 'profile'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RoleBasedBottomNav extends StatelessWidget {
  final int currentIndex;
  final String role;
  final Function(int) onTap;

  const RoleBasedBottomNav({
    super.key,
    required this.currentIndex,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [];

    if (role == 'FERMIER') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Animaux"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historique"),
      ];
    } else if (role == 'VETERINAIRE') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Santé"),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Dossier"),
      ];
    } else if (role == 'CONTROLEUR') {
      items = const [
        BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Check"),
        BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: "Constat"),
      ];
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
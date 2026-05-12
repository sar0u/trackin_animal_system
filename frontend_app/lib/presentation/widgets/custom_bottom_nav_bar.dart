import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        // La navigation sera gérée dans chaque écran
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.nfc), label: "Scan"),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Fiche"),
        BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Santé"),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: "Constat"),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FermierDashboardScreen extends StatelessWidget {
  const FermierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tableau de Bord",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Statistiques
            Row(
              children: [
                _statCard("Animaux", "142", Icons.pets, Colors.green),
                const SizedBox(width: 12),
                _statCard("Vendus", "23", Icons.sell, Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statCard("Vaccins", "89", Icons.vaccines, Colors.orange),
                const SizedBox(width: 12),
                _statCard("Alertes", "3", Icons.warning, Colors.red),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Derniers animaux scannés",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Tu peux lier ici avec le provider
            const Text("Dernier scan : 2024-MA-99238 - 14h22"),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
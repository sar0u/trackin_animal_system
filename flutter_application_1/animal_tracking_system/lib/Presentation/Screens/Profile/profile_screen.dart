import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'profile'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Ajoutez une image
            ),
            const SizedBox(height: 16),
            const Text('Selmani Sarah', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('sarah@example.com'),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppTranslations.translate(context, 'editProfile')),
              onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(AppTranslations.translate(context, 'changePassword')),
              onTap: () => Navigator.pushNamed(context, '/change-password'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppTranslations.translate(context, 'settings')),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(AppTranslations.translate(context, 'helpSupport')),
              onTap: () => Navigator.pushNamed(context, '/help-support'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Déconnexion
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
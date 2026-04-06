import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'helpSupport'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contactez-nous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@tracedz.dz'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: const Text('+213 21 123 456'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat en Direct'),
              subtitle: const Text('Disponible 9h-18h'),
              onTap: () {},
            ),
            const Divider(),
            const Text('FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Comment scanner un QR code ?'),
            const Text('• Comment signaler une fraude ?'),
            // Ajoutez plus de FAQ
          ],
        ),
      ),
    );
  }
}
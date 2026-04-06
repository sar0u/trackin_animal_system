import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Widgets/Common/custom_button.dart';

class ScanRfidScreen extends StatefulWidget {
  const ScanRfidScreen({super.key});

  @override
  State<ScanRfidScreen> createState() => _ScanRfidScreenState();
}

class _ScanRfidScreenState extends State<ScanRfidScreen> {
  String? _scannedId;

  void _scanRfid() {
    // TODO: Intégrer scanner RFID réel
    setState(() {
      _scannedId = 'DZ-24-99812';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('RFID Scanné avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'scanRfid'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 120, color: Colors.grey),
            const SizedBox(height: 32),
            Text(
              _scannedId != null ? 'ID Scanné: $_scannedId' : 'Approchez la puce RFID',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Scanner RFID',
              onPressed: _scanRfid,
              icon: Icons.nfc,
            ),
            if (_scannedId != null) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: 'Voir Passeport',
                onPressed: () => Navigator.pushNamed(context, '/animal-passport'),
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScannerService {
  /// Ouvre l'écran de scan et retourne l'identifiant scanné
  static Future<String?> scan(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const _ScannerScreen(),
      ),
    );
  }
}

class _ScannerScreen extends StatefulWidget {
  const _ScannerScreen();

  @override
  State<_ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<_ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner RFID / QR Code"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour activer/désactiver le flash
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          // Bouton pour changer de caméra
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Vue caméra
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? value = barcode.rawValue;
                if (value != null && value.isNotEmpty) {
                  _hasScanned = true;
                  Navigator.pop(context, value);
                  return;
                }
              }
            },
          ),

          // Overlay avec cadre de scan
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instructions en bas
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Pointez la caméra vers le QR Code ou le code-barres de la boucle RFID",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          // Bouton saisie manuelle
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: TextButton(
              onPressed: () async {
                final result = await _showManualInput(context);
                if (result != null && result.isNotEmpty && mounted) {
                  Navigator.pop(context, result);
                }
              },
              child: const Text(
                "Saisir l'identifiant manuellement",
                style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showManualInput(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Saisie manuelle"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Ex: 2024-MA-99238",
            labelText: "Identifiant RFID",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }
}
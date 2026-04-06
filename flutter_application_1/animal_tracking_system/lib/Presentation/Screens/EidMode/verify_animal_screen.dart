import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../Widgets/Common/app_badge.dart';
import '../../Widgets/Common/section_title.dart';

class VerifyAnimalScreen extends StatefulWidget {
  const VerifyAnimalScreen({super.key});

  @override
  State<VerifyAnimalScreen> createState() => _VerifyAnimalScreenState();
}

class _VerifyAnimalScreenState extends State<VerifyAnimalScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  bool hasResult = false;
  bool verified = true;
  String scannedId = '';

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController c) {
    controller = c;
    c.scannedDataStream.listen((scanData) {
      if (hasResult) return;
      setState(() {
        hasResult = true;
        scannedId = scanData.code ?? '';
        verified = scannedId.isNotEmpty && !scannedId.contains('ILLEGAL'); // mock logic
      });
      controller?.pauseCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Livestock'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                hasResult = false;
                scannedId = '';
                verified = true;
              });
              controller?.resumeCamera();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 240,
              child: hasResult
                  ? _ResultCard(
                id: scannedId.isEmpty ? 'DZ-2024-XXXXX' : scannedId,
                verified: verified,
              )
                  : QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: cs.primary,
                  borderRadius: 18,
                  borderLength: 28,
                  borderWidth: 8,
                  cutOutSize: 230,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const SectionTitle(title: 'Actions'),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasResult
                      ? () => Navigator.pushNamed(context, '/animal-passport')
                      : null,
                  icon: const Icon(Icons.badge_rounded),
                  label: const Text('View Passport'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/create-report', arguments: {'type': 'illegal_sale'}),
                  icon: const Icon(Icons.report_problem_rounded),
                  label: const Text('Report'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.map_rounded, color: cs.primary),
              ),
              title: const Text('View Authorized Markets', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('Find verified markets near you.', style: TextStyle(color: Colors.grey.shade700)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, '/map'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String id;
  final bool verified;

  const _ResultCard({required this.id, required this.verified});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = verified ? AppColors.successGreen : AppColors.dangerRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.16),
            cs.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(verified ? Icons.verified_rounded : Icons.gpp_bad_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  verified ? 'Verified & Healthy' : 'Illegal / Unverified',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
                ),
              ),
              AppBadge(text: verified ? 'OK' : 'ALERT', color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text('ID: $id', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            verified
                ? 'Official record found. Health screening is valid.'
                : 'No official record found. Avoid purchase and report if needed.',
            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
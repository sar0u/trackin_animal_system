import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../Widgets/Common/section_title.dart';

class EidHomeScreen extends StatelessWidget {
  const EidHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TraceDZ • Citizen Portal'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.language_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.verified_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Livestock Verification',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ensure your sacrifice is healthy and officially registered.',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/verify-animal'),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Scan Ear Tag QR'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/verify-animal'),
                      icon: const Icon(Icons.keyboard_rounded),
                      label: const Text('Enter ID Manually'),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 240.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 12),
          const SectionTitle(title: 'Nearby Authorized Markets'),
          const SizedBox(height: 10),

          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/map'),
              child: SizedBox(
                height: 170,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary.withOpacity(.12), cs.primary.withOpacity(.04)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      top: 14,
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_rounded),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Official Markets',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withOpacity(.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('Open Map', style: TextStyle(fontWeight: FontWeight.w900)),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Text(
                        'Tap to view verified markets and avoid illegal sales.',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 12),
          const SectionTitle(title: 'Report'),
          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.report_problem_rounded, color: AppColors.dangerRed),
              ),
              title: const Text('Report Illegal Sale', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('Help keep citizens safe.', style: TextStyle(color: Colors.grey.shade700)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, '/create-report', arguments: {'type': 'illegal_sale'}),
            ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: .08, end: 0),
        ],
      ),
    );
  }
}
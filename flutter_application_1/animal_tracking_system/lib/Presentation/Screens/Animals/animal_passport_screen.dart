import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../../Data/Models/animal_model.dart';
import '../../Widgets/Common/section_title.dart';
import '../../Widgets/Cards/health_certificate_widget.dart';
import '../../Widgets/Common/app_badge.dart';

class AnimalPassportScreen extends StatelessWidget {
  // Le modèle est maintenant passé en argument
  final AnimalModel animal;
  const AnimalPassportScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${animal.name} - DNA Profile'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Carte principale
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 78,
                          height: 78,
                          color: cs.primary.withOpacity(.10),
                          child: const Icon(Icons.pets_rounded, size: 42),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(animal.id, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text('RFID: ${animal.rfid}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {}, // Fonction copier
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (animal.isVerified) AppBadge(text: 'VERIFIED', color: AppColors.successGreen),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Bloc statut dynamique
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (animal.status == 'Healthy') ? cs.primary.withOpacity(.08) : AppColors.dangerRed.withOpacity(.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: (animal.status == 'Healthy') ? cs.primary : AppColors.dangerRed),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon((animal.status == 'Healthy') ? Icons.favorite_rounded : Icons.error_rounded, color: (animal.status == 'Healthy') ? AppColors.successGreen : AppColors.dangerRed),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Status: ${animal.status}', style: const TextStyle(fontWeight: FontWeight.w900))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Last screening: 2 hours ago.', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => showDialog(context: context, builder: (_) => const HealthCertificateWidget()),
                            icon: const Icon(Icons.verified_rounded),
                            label: const Text('View Health Certificate'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 10),

          // Metrics Grid
          Row(
            children: [
              Expanded(child: _MiniMetric(icon: Icons.badge_outlined, label: 'BREED', value: animal.breed)),
              const SizedBox(width: 10),
              Expanded(child: _MiniMetric(icon: Icons.cake_outlined, label: 'AGE', value: '${animal.age} Years')),
              const SizedBox(width: 10),
              Expanded(child: _MiniMetric(icon: Icons.scale_outlined, label: 'WEIGHT', value: '${animal.weight} kg')),
            ],
          ).animate().fadeIn(duration: 280.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 14),

          // Timeline fictive pour l'exemple
          const SectionTitle(title: 'History Registry'),
          const SizedBox(height: 10),
          Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.history, color: cs.primary),
                title: Text('Born on ${animal.birthDate.day}/${animal.birthDate.month}/${animal.birthDate.year}'),
                subtitle: const Text('Farm Registration'),
              )
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniMetric({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w800, fontSize: 11)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
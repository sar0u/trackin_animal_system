import 'package:flutter/material.dart';
import 'package:tracedz/Presentation/Widgets/Cards/signature_placeholder.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../../Core/Utils/app_translations.dart';

class HealthCertificateWidget extends StatelessWidget {
  const HealthCertificateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête officielle verte
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(.12),
                border: Border(bottom: BorderSide(color: cs.primary.withOpacity(.2), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.successGreen.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: -2
                          )
                        ]
                    ),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CERTIFICAT DE SANTÉ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreenDark
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'TraceDZ • Ministère de l\'Agriculture',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.successGreen, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('VALID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu du Document
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Principal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#HC-2024-DZ-882', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                      Chip(
                        label: const Text('Original'),
                        backgroundColor: AppColors.primaryGreen.withOpacity(.1),
                        side: BorderSide(color: AppColors.primaryGreen, width: 1),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Informations Animales
                  _InfoRow(label: 'Numéro RFID', value: '824 000 129 384 556'),
                  _InfoRow(label: 'Espèce', value: 'Ovin • Ouled Djellal'),
                  _InfoRow(label: 'Date de Naissance', value: '12/03/2021'),

                  const Divider(height: 32, thickness: 1),

                  // Statut de Vérification
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.successGreen.withOpacity(.2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.successGreen,
                          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ANIMAL EN BONNE SANTÉ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Dernier examen: Il y a 2 heures. Aucune restriction épidémique.',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Emplacement Signature
                  Row(
                    children: [
                      Expanded(child: SignaturePlaceholder(signatoryName: 'Dr. Ahmed Benali')),
                      const SizedBox(width: 24),
                      Expanded(child: _DigitalStamp()),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Télécharger PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreenDark,
                    side: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Ligne d'information propre
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder Signature Vétérinaire
class _SignaturePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vétérinaire Autorisé', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: const Center(
            child: Text('(Signature Numérique)', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
          ),
        ),
        const SizedBox(height: 4),
        Text('Dr. Ahmed BENALI', style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Petit tampon numérique style officiel
class _DigitalStamp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Cachet Officiel', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen.withOpacity(0.1),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'TRACE\nDZ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
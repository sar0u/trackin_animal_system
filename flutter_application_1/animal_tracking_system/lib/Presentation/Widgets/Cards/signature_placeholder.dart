import 'package:flutter/material.dart';


class SignaturePlaceholder extends StatelessWidget {
  final String? signatoryName;

  const SignaturePlaceholder({
    super.key,
    this.signatoryName = 'Dr. Ahmed Benali',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signature Vétérinaire',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          height: 42,
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBDBDBD), width: 1),
            ),
          ),
          child: const Center(
            child: Text(
              '✓ Signature Numérique Certifiée',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          signatoryName!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
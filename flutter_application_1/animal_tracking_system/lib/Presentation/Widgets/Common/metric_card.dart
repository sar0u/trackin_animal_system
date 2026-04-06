import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final String? delta;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    this.delta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: tint.withOpacity(.22)),
                ),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.primary.withOpacity(.18)),
                  ),
                  child: Text(delta!, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900)),
                )
            ],
          ),
        ),
      ),
    );
  }
}
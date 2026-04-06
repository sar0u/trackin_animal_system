import 'package:flutter/material.dart';

class GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const GlassChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(.16) : cs.surface.withOpacity(.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? cs.primary.withOpacity(.25) : cs.primary.withOpacity(.12),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: -10,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(.08),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? cs.primary : cs.primary.withOpacity(.8)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
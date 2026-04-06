import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Widgets/Common/app_icon_button.dart';
import '../../Widgets/Common/app_search_field.dart';
import '../../Widgets/Cards/farm_card.dart';

class FarmsListScreen extends StatefulWidget {
  const FarmsListScreen({super.key});

  @override
  State<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends State<FarmsListScreen> {
  final _search = TextEditingController();

  // Filtres UI (frontend only)
  String? selectedWilaya;
  String statusFilter = 'All'; // All, Verified, Suspect
  String sortBy = 'Name'; // Name, Capacity, Occupancy

  final wilayas = const ['Algiers', 'Blida', 'Tiaret', 'Djelfa', 'Sétif'];

  // Mock data (remplacer plus tard par data layer)
  final farms = const [
    {
      'name': 'El-Wahat North',
      'location': 'Djelfa',
      'capacity': 600,
      'current': 450,
      'status': 'Suspect',
    },
    {
      'name': 'Medea Farm',
      'location': 'Blida',
      'capacity': 400,
      'current': 320,
      'status': 'Verified',
    },
    {
      'name': 'Al-Amal Livestock',
      'location': 'Tiaret',
      'capacity': 900,
      'current': 880,
      'status': 'Verified',
    },
    {
      'name': 'Souk Ahras Unit',
      'location': 'Algiers',
      'capacity': 300,
      'current': 120,
      'status': 'Suspect',
    },
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        String? tmpWilaya = selectedWilaya;
        String tmpStatus = statusFilter;
        String tmpSort = sortBy;

        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune),
                      const SizedBox(width: 8),
                      const Text(
                        'Filtres',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheet(() {
                            tmpWilaya = null;
                            tmpStatus = 'All';
                            tmpSort = 'Name';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Wilaya
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Wilaya', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('Toutes'),
                        selected: tmpWilaya == null,
                        onSelected: (_) => setSheet(() => tmpWilaya = null),
                      ),
                      ...wilayas.map(
                            (w) => ChoiceChip(
                          label: Text(w),
                          selected: tmpWilaya == w,
                          onSelected: (_) => setSheet(() => tmpWilaya = w),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Statut', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: tmpStatus == 'All',
                        onSelected: (_) => setSheet(() => tmpStatus = 'All'),
                      ),
                      ChoiceChip(
                        label: const Text('Verified'),
                        selected: tmpStatus == 'Verified',
                        onSelected: (_) => setSheet(() => tmpStatus = 'Verified'),
                      ),
                      ChoiceChip(
                        label: const Text('Suspect'),
                        selected: tmpStatus == 'Suspect',
                        onSelected: (_) => setSheet(() => tmpStatus = 'Suspect'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sort
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Trier par', style: TextStyle(color: Colors.grey.shade700)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tmpSort,
                    items: const [
                      DropdownMenuItem(value: 'Name', child: Text('Nom')),
                      DropdownMenuItem(value: 'Capacity', child: Text('Capacité')),
                      DropdownMenuItem(value: 'Occupancy', child: Text('Occupation')),
                    ],
                    onChanged: (v) => setSheet(() => tmpSort = v ?? 'Name'),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedWilaya = tmpWilaya;
                          statusFilter = tmpStatus;
                          sortBy = tmpSort;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _computeList() {
    final q = _search.text.trim().toLowerCase();
    var list = farms.map((e) => Map<String, dynamic>.from(e)).toList();

    if (selectedWilaya != null) {
      list = list.where((f) => (f['location'] as String) == selectedWilaya).toList();
    }

    if (statusFilter != 'All') {
      list = list.where((f) => (f['status'] as String) == statusFilter).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((f) {
        final name = (f['name'] as String).toLowerCase();
        final loc = (f['location'] as String).toLowerCase();
        return name.contains(q) || loc.contains(q);
      }).toList();
    }

    // sort
    list.sort((a, b) {
      if (sortBy == 'Capacity') {
        return (b['capacity'] as int).compareTo(a['capacity'] as int);
      }
      if (sortBy == 'Occupancy') {
        final occA = (a['current'] as int) / (a['capacity'] as int);
        final occB = (b['current'] as int) / (b['capacity'] as int);
        return occB.compareTo(occA);
      }
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _computeList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate(context, 'farmList')),
        actions: [
          AppIconButton(
            icon: Icons.tune,
            tooltip: 'Filtres',
            onTap: _openFilters,
          ),
          const SizedBox(width: 10),
          AppIconButton(
            icon: Icons.add,
            tooltip: 'Ajouter',
            onTap: () => Navigator.pushNamed(context, '/add-farm'),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          AppSearchField(
            controller: _search,
            hint: 'Rechercher une ferme, wilaya...',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Quick chips summary
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterPill(
                icon: Icons.location_on_outlined,
                label: selectedWilaya ?? 'Toutes wilayas',
                active: selectedWilaya != null,
                onTap: _openFilters,
              ),
              _FilterPill(
                icon: Icons.verified_outlined,
                label: 'Status: $statusFilter',
                active: statusFilter != 'All',
                onTap: _openFilters,
              ),
              _FilterPill(
                icon: Icons.sort,
                label: 'Tri: $sortBy',
                active: true,
                onTap: _openFilters,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '${list.length} résultat(s)',
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 10),

          ...list.map((f) {
            final cap = f['capacity'] as int;
            final cur = f['current'] as int;
            final status = f['status'] as String;
            final percent = (cur / cap * 100).clamp(0, 100).toDouble();

            return FarmCard(
              name: f['name'] as String,
              location: f['location'] as String,
              capacity: '$cur / $cap',
              status: status,
              occupancyPercent: percent,
              onTap: () => Navigator.pushNamed(context, '/farm-detail'),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? cs.primary.withOpacity(.12) : const Color(0xFFF1F4F2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.primary.withOpacity(active ? .18 : .10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
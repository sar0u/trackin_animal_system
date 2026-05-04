import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/animal_model.dart';
import '../../../services/qr_scanner_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fermier_provider.dart';
import '../../widgets/edit_animal_dialog.dart';
import '../alerts/health_alert_screen.dart';
import '../movement_screen.dart';
import '../sync/sync_screen.dart';
import 'add_animal_dialog.dart';


class FermierHomeScreen extends StatefulWidget {
  const FermierHomeScreen({super.key});

  @override
  State<FermierHomeScreen> createState() => _FermierHomeScreenState();
}

class _FermierHomeScreenState extends State<FermierHomeScreen> {
  final TextEditingController _rfidController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<FermierProvider>(context, listen: false);
      p.loadStats();
      p.loadMyAnimals();
      p.loadMyAlerts();
    });
  }

  @override
  void dispose() {
    _rfidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FermierProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Espace Fermier"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final p = Provider.of<FermierProvider>(context, listen: false);
              p.loadStats();
              p.loadMyAnimals();
              p.loadMyAlerts();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddAnimalDialog(),
        ),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
      )
          : null,
      body: SafeArea(child: _buildBody(provider)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Animaux"),
        ],
      ),
    );
  }

  Widget _buildBody(FermierProvider provider) {
    switch (_currentIndex) {
      case 0: return _buildDashboard(provider);
      case 1: return _buildScanPage(provider);
      case 2: return _buildMyAnimalsPage(provider);
      default: return _buildDashboard(provider);
    }
  }

  Widget _buildDashboard(FermierProvider provider) {
    if (provider.isLoadingStats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    final stats = provider.stats;

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadStats();
        await provider.loadMyAnimals();
        await provider.loadMyAlerts();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stats?.farmName ?? "Mon Exploitation",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(children: [
              _statCard("Total", stats?.totalAnimaux.toString() ?? "-", Icons.pets, AppColors.primaryGreen),
              const SizedBox(width: 12),
              _statCard("Actifs", stats?.animauxActifs.toString() ?? "-", Icons.check_circle, Colors.blue),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statCard("Vendus", stats?.animauxVendus.toString() ?? "-", Icons.sell, Colors.orange),
              const SizedBox(width: 12),
              _statCard("Décédés", stats?.animauxMorts.toString() ?? "-", Icons.remove_circle, Colors.red),
            ]),

            const SizedBox(height: 20),

            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthAlertScreen())),
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  label: const Text("Alertes", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncScreen())),
                  icon: const Icon(Icons.sync),
                  label: const Text("Synchroniser"),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                ),
              ),
            ]),

            if (provider.isLoadingAlerts) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ] else if (provider.myAlerts.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                "🔔 Alertes Sanitaires",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...provider.myAlerts.take(5).map((alert) {
                final severity = alert['severity']?.toString() ?? 'INFO';
                final color = severity == 'CRITICAL'
                    ? Colors.red
                    : severity == 'WARNING'
                    ? Colors.orange
                    : Colors.blue;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        severity == 'CRITICAL' ? Icons.error : Icons.warning_amber,
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Animal : ${alert['animalRfidTag'] ?? ''}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              alert['message']?.toString() ?? '',
                              style: TextStyle(color: color, fontSize: 13),
                            ),
                            Text(
                              "Date : ${alert['dueDate'] ?? ''}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            if (provider.animal != null) ...[
              const SizedBox(height: 24),
              const Text(
                "Dernier animal scanné",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildAnimalCard(provider.animal!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanPage(FermierProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Scanner une puce", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Icon(Icons.qr_code_scanner, size: 60, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await QrScannerService.scanWithCamera(context);
                    if (result != null) {
                      _rfidController.text = result;
                      await provider.loadAnimalFromScan(result);
                    }
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Scanner Caméra", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final r = await provider.scanNfcAndLoadAnimal();
                    if (r == "NFC_UNAVAILABLE" && mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("NFC indisponible"),
                          content: const Text("Utilisez la caméra ou la saisie manuelle."),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.nfc),
                  label: const Text("Scan NFC"),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _rfidController,
                decoration: const InputDecoration(
                  hintText: "EX: 2024-MA-99238",
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => provider.searchAnimalByRfid(_rfidController.text.trim()),
              child: const Text("Vérifier"),
            ),
          ]),
          const SizedBox(height: 24),
          if (provider.isLoading) const Center(child: CircularProgressIndicator()),
          if (provider.error != null) _msgCard(provider.error!, true),
          if (provider.success != null) _msgCard(provider.success!, false),
          if (provider.animal != null) _buildAnimalCard(provider.animal!),
        ],
      ),
    );
  }

  Widget _buildMyAnimalsPage(FermierProvider provider) {
    if (provider.isLoadingMyAnimals) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.myAnimals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Aucun animal", style: TextStyle(fontSize: 18, color: AppColors.textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showDialog(context: context, builder: (_) => const AddAnimalDialog()),
              child: const Text("Ajouter un animal"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadMyAnimals(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.myAnimals.length,
        itemBuilder: (context, index) {
          final animal = provider.myAnimals[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.pets, color: AppColors.primaryGreen),
              ),
              title: Text(animal.rfidTag, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${animal.species} • ${animal.breed ?? '-'}\nStatut : ${animal.status}",
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (_) => EditAnimalDialog(animal: animal),
                    );
                  }
                  if (value == 'movement') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovementScreen(
                          animalId: animal.id,
                          animalRfid: animal.rfidTag,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text("Modifier"),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'movement',
                    child: Row(children: [
                      Icon(Icons.swap_horiz, color: AppColors.primaryGreen),
                      SizedBox(width: 8),
                      Text("Mouvements"),
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalCard(AnimalModel animal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ID: ${animal.rfidTag}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
          const SizedBox(height: 8),
          Text("Espèce : ${animal.species}"),
          Text("Race : ${animal.breed ?? '-'}"),
          Text("Poids : ${animal.weight ?? '-'} kg"),
          Text("Statut : ${animal.status}"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.location_on, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(animal.farmName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _msgCard(String msg, bool isError) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEBEE) : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        msg,
        style: TextStyle(
          color: isError ? AppColors.danger : AppColors.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
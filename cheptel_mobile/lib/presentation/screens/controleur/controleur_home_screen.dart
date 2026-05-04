import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/farm_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/controleur_provider.dart';
import '../constat/constat_screen.dart';
import 'uhf_camera_scanner_screen.dart';

class ControleurHomeScreen extends StatefulWidget {
  const ControleurHomeScreen({super.key});

  @override
  State<ControleurHomeScreen> createState() => _ControleurHomeScreenState();
}

class _ControleurHomeScreenState extends State<ControleurHomeScreen> {
  final TextEditingController _manualTagController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ControleurProvider>(
        context,
        listen: false,
      ).loadFarms();
    });
  }

  @override
  void dispose() {
    _manualTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ControleurProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Espace Contrôleur",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, provider),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check),
            label: "Check",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Constat",
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ControleurProvider provider,
      ) {
    switch (_currentIndex) {
      case 0:
        return _buildScanPage(context, provider);
      case 1:
        return _buildCheckPage(context, provider);
      case 2:
        return _buildConstatPage(context, provider);
      default:
        return _buildScanPage(context, provider);
    }
  }

  // ==========================================================
  // PAGE 1 : SCAN
  // ==========================================================

  Widget _buildScanPage(
      BuildContext context,
      ControleurProvider provider,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SESSION D'AUDIT ACTIVE",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "Vérification de l'Effectif",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 24),

          // ✅ Sélecteur de ferme (données réelles)
          _buildFarmSelector(provider),

          const SizedBox(height: 20),

          // ✅ Boutons de scan
          _buildScanCard(context, provider),

          const SizedBox(height: 20),

          // ✅ Saisie manuelle
          _buildManualInput(provider),

          const SizedBox(height: 20),

          // ✅ Compteur
          _buildCounter(provider),

          const SizedBox(height: 16),

          // ✅ Liste tags
          _buildTagsList(provider),

          // Messages
          if (provider.error != null) ...[
            const SizedBox(height: 12),
            _buildMessageCard(provider.error!, isError: true),
          ],

          if (provider.success != null) ...[
            const SizedBox(height: 12),
            _buildMessageCard(provider.success!, isError: false),
          ],
        ],
      ),
    );
  }

  Widget _buildFarmSelector(ControleurProvider provider) {
    if (provider.isLoadingFarms) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: 12),
            Text("Chargement des fermes..."),
          ],
        ),
      );
    }

    if (provider.farms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aucune ferme disponible dans la base de données.",
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => provider.loadFarms(),
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "FERME À CONTRÔLER",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<int>(
            value: provider.selectedFarm?.id,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.agriculture,
                color: AppColors.primaryGreen,
              ),
              hintText: "Sélectionnez une ferme",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: provider.farms.map((FarmModel farm) {
              return DropdownMenuItem<int>(
                value: farm.id,
                child: Text(
                  farm.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (int? farmId) {
              if (farmId == null) return;

              final farm = provider.farms.firstWhere(
                    (f) => f.id == farmId,
              );

              provider.selectFarm(farm);
            },
          ),

          if (provider.selectedFarm != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ferme sélectionnée : ${provider.selectedFarm!.name}",
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanCard(
      BuildContext context,
      ControleurProvider provider,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sensors,
            size: 65,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 14),

          const Text(
            "Scan UHF / Caméra",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "Scannez les boucles avec la caméra pour lire les tags.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                final result = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UhfCameraScannerScreen(),
                  ),
                );

                if (result != null && result.isNotEmpty) {
                  provider.addScannedTags(result);
                }
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                "Démarrer Scan Caméra",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput(ControleurProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SAISIE MANUELLE",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualTagController,
                  decoration: InputDecoration(
                    hintText: "Saisir tag manuellement",
                    prefixIcon: const Icon(Icons.tag),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  final tag = _manualTagController.text.trim();

                  if (tag.isNotEmpty) {
                    provider.addManualTag(tag);
                    _manualTagController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(ControleurProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Text(
            "${provider.detectedCount}",
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const Text(
            "ANIMAUX DÉTECTÉS",
            style: TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(ControleurProvider provider) {
    final tags = provider.scannedTags;

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tags scannés (${tags.length})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          ...tags.map(
                (tag) => ListTile(
              dense: true,
              leading: const Icon(
                Icons.label,
                color: AppColors.primaryGreen,
              ),
              title: Text(tag),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => provider.removeTag(tag),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAGE 2 : CHECK
  // ==========================================================

  Widget _buildCheckPage(
      BuildContext context,
      ControleurProvider provider,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "VÉRIFICATION DE L'EFFECTIF",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "Comparaison avec la base de données",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 20),

          _buildCounter(provider),

          const SizedBox(height: 20),

          if (provider.selectedFarm != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.agriculture,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Ferme : ${provider.selectedFarm!.name}",
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "⚠️ Aucune ferme sélectionnée. Allez dans l'onglet Scan.",
                style: TextStyle(color: AppColors.danger),
              ),
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  provider.scannedTags.isNotEmpty &&
                      provider.selectedFarm != null &&
                      !provider.isLoading
                      ? () async {
                    await provider.performCheck();
                  }
                      : null,
                  icon: const Icon(Icons.fact_check, color: Colors.white),
                  label: const Text(
                    "CHECK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: provider.resetScan,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réinitialiser"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (provider.isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            ),

          if (provider.error != null)
            _buildMessageCard(provider.error!, isError: true),

          if (provider.checkResult != null)
            _buildCheckResult(context, provider),
        ],
      ),
    );
  }

  Widget _buildCheckResult(
      BuildContext context,
      ControleurProvider provider,
      ) {
    final result = provider.checkResult!;
    final isOk = result.result == "OK";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isOk ? Colors.green : AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOk ? Icons.check_circle : Icons.warning,
                color: isOk ? Colors.green : AppColors.warning,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isOk ? "Effectif conforme ✅" : "Écart détecté ⚠️",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _resultRow("Attendus en base", result.expectedCount),
          _resultRow("Détectés sur terrain", result.detectedCount),
          _resultRow(
            "Manquants",
            result.missingCount,
            color: result.missingCount > 0 ? AppColors.danger : null,
          ),
          _resultRow(
            "Inconnus (hors liste)",
            result.unknownCount,
            color: result.unknownCount > 0 ? AppColors.warning : null,
          ),

          if (result.missingTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              "Tags manquants :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            ...result.missingTags.map(
                  (tag) => Text(
                "• $tag",
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],

          if (result.unknownTags.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              "Tags inconnus :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            ...result.unknownTags.map(
                  (tag) => Text(
                "• $tag",
                style: const TextStyle(color: AppColors.warning),
              ),
            ),
          ],

          if (!isOk) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConstatScreen(
                        farmId: result.farmId,
                        controlSessionId: result.sessionId,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.report_problem,
                  color: Colors.white,
                ),
                label: const Text(
                  "Déclarer un Constat",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // PAGE 3 : CONSTAT
  // ==========================================================

  Widget _buildConstatPage(
      BuildContext context,
      ControleurProvider provider,
      ) {
    final result = provider.checkResult;
    final hasEcart = result != null && result.result != "OK";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.report_problem,
                size: 72,
                color: hasEcart ? AppColors.danger : Colors.grey,
              ),
              const SizedBox(height: 16),

              const Text(
                "Déclaration de Constat",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                hasEcart
                    ? "Un écart a été détecté lors du CHECK.\nVous pouvez déclarer un constat officiel."
                    : "Aucun écart détecté.\nEffectuez un CHECK dans l'onglet Check pour activer cette option.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: hasEcart
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConstatScreen(
                          farmId: result.farmId,
                          controlSessionId: result.sessionId,
                        ),
                      ),
                    );
                  }
                      : null,
                  icon: const Icon(
                    Icons.edit_document,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Ouvrir Déclaration",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                ),
              ),

              if (!hasEcart) ...[
                const SizedBox(height: 12),
                const Text(
                  "Allez dans 'Scan' → sélectionnez une ferme → scannez les animaux → puis 'Check'.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // WIDGETS COMMUNS
  // ==========================================================

  Widget _resultRow(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: color ?? AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message, {required bool isError}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFEBEE)
            : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? AppColors.danger : AppColors.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
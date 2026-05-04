import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/health_sheet_model.dart';
import '../../../services/qr_scanner_service.dart';

import '../../providers/auth_provider.dart';
import '../../providers/veterinaire_provider.dart';

import '../../widgets/add_health_record_dialog.dart';
import '../../widgets/add_vaccination_dialog.dart';
import 'campaigns_screen.dart';

class VeterinaireHomeScreen extends StatefulWidget {
  const VeterinaireHomeScreen({super.key});

  @override
  State<VeterinaireHomeScreen> createState() => _VeterinaireHomeScreenState();
}

class _VeterinaireHomeScreenState extends State<VeterinaireHomeScreen> {
  final TextEditingController _rfidController = TextEditingController();
  int _currentIndex = 0;
  int? _selectedFarmId;
  String? _selectedFarmName;

  final List<Map<String, dynamic>> _staticFarms = [
    {'id': 1, 'name': 'Ferme Al-Baraka'},
    {'id': 2, 'name': 'Domaine des Plaines'},
  ];

  @override
  void dispose() {
    _rfidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VeterinaireProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Espace Vétérinaire',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(provider),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Santé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Dossier',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(VeterinaireProvider provider) {
    switch (_currentIndex) {
      case 0:
        return _buildScanPage(provider);
      case 1:
        return _buildHealthPage(provider);
      case 2:
        return _buildMedicalFilePage(provider);
      default:
        return _buildScanPage(provider);
    }
  }

  // =========================================================
  // PAGE 1 : SCAN
  // =========================================================

  Widget _buildScanPage(VeterinaireProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESPACE VÉTÉRINAIRE',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fiche Santé Animal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),

            // Sélecteur de ferme
            _buildFarmSelector(),
            const SizedBox(height: 20),

            // Section scan
            _buildScanSection(provider),
            const SizedBox(height: 20),

            // Bouton Campagnes Sanitaires
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CampaignsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.campaign,
                  color: Colors.white,
                ),
                label: const Text(
                  'Campagnes Sanitaires',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Messages
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),

            if (provider.error != null)
              _buildErrorCard(provider.error!),

            if (provider.successMessage != null)
              _buildSuccessCard(provider.successMessage!),

            if (provider.healthSheet != null)
              _buildHealthSheetCard(provider.healthSheet!),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FERME D\'INTERVENTION',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _selectedFarmId,
            decoration: InputDecoration(
              hintText: 'Sélectionnez une ferme',
              prefixIcon: const Icon(Icons.agriculture),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _staticFarms.map((farm) {
              return DropdownMenuItem<int>(
                value: farm['id'] as int,
                child: Text(farm['name'] as String),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFarmId = value;
                _selectedFarmName = _staticFarms
                    .firstWhere((f) => f['id'] == value)['name'] as String;
              });
            },
          ),
          if (_selectedFarmName != null) ...[
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
                  Text(
                    'Ferme : $_selectedFarmName',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildScanSection(VeterinaireProvider provider) {
    final bool farmSelected = _selectedFarmId != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: farmSelected ? AppColors.primaryGreen : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan Médical',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            farmSelected
                ? 'Scannez la boucle RFID ou saisissez l\'identifiant.'
                : 'Veuillez d\'abord sélectionner une ferme.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),

          // Champ saisie manuelle
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _rfidController,
                  enabled: farmSelected,
                  decoration: InputDecoration(
                    hintText: 'EX: ID-0007',
                    prefixIcon: const Icon(Icons.tag),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: !farmSelected || provider.isLoading
                      ? null
                      : () async {
                    final rfid = _rfidController.text.trim();
                    if (rfid.isEmpty) return;
                    await provider.searchHealthSheet(rfid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bouton caméra
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: !farmSelected || provider.isLoading
                  ? null
                  : () async {
                final result = await QrScannerService.scanWithCamera(context);
                if (result != null && result.isNotEmpty) {
                  _rfidController.text = result;
                  await provider.searchHealthSheet(result);
                }
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Scanner avec Caméra',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bouton NFC
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: !farmSelected || provider.isLoading
                  ? null
                  : () async {
                final result = await provider.scanAndLoadHealthSheet();
                if (result == 'NFC_UNAVAILABLE' && mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('NFC indisponible'),
                      content: const Text(
                        'NFC non disponible. Utilisez la caméra ou la saisie manuelle.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(Icons.nfc),
              label: const Text(
                'Démarrer Scan NFC',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PAGE 2 : FICHE SANTÉ
  // =========================================================

  Widget _buildHealthPage(VeterinaireProvider provider) {
    final sheet = provider.healthSheet;

    if (sheet == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aucune fiche chargée.\nScannez un animal depuis l\'onglet Scan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildHealthSheetCard(sheet),
    );
  }

  Widget _buildHealthSheetCard(HealthSheetModel sheet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fiche Santé : ${_formatSpecies(sheet.species)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '#${sheet.rfidTag}',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _infoRow('État', sheet.status ?? '—', Icons.health_and_safety),
                    const Divider(),
                    _infoRow('Race', sheet.breed ?? '—', Icons.badge),
                    const Divider(),
                    _infoRow(
                      'Poids',
                      sheet.weight != null ? '${sheet.weight} kg' : '—',
                      Icons.monitor_weight,
                    ),
                    const Divider(),
                    _infoRow('Ferme', sheet.farmName ?? '—', Icons.location_on),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Vaccins
        const Text(
          'Historique des Vaccins',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (sheet.vaccinations.isEmpty)
          _emptyState('Aucun vaccin enregistré.')
        else
          ...sheet.vaccinations.map((v) => _vaccinCard(v)),

        const SizedBox(height: 24),

        // Dossiers médicaux
        const Text(
          'Maladies & Traitements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (sheet.healthRecords.isEmpty)
          _emptyState('Aucun historique médical.')
        else
          ...sheet.healthRecords.map((r) => _healthRecordCard(r)),
      ],
    );
  }

  // =========================================================
  // PAGE 3 : DOSSIER MÉDICAL
  // =========================================================

  Widget _buildMedicalFilePage(VeterinaireProvider provider) {
    final sheet = provider.healthSheet;
    final rfidTag = provider.lastScannedTag ?? sheet?.rfidTag;

    if (rfidTag == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Scannez d\'abord un animal pour ajouter un dossier médical.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Icon(Icons.medical_services, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            const Text(
              'Dossier Médical',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Animal : $rfidTag',
              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Ajouter vaccination
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () {
                  showDialog(
                    context: context,
                    builder: (_) => AddVaccinationDialog(rfidTag: rfidTag),
                  );
                },
                icon: const Icon(Icons.vaccines, color: Colors.white),
                label: const Text(
                  'Ajouter une Vaccination',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Ajouter consultation
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () {
                  showDialog(
                    context: context,
                    builder: (_) => AddHealthRecordDialog(rfidTag: rfidTag),
                  );
                },
                icon: const Icon(Icons.note_add, color: Colors.white),
                label: const Text(
                  'Ajouter une Consultation',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Campagnes sanitaires
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CampaignsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.campaign),
                label: const Text(
                  'Campagnes Sanitaires',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // WIDGETS COMMUNS
  // =========================================================

  Widget _infoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.textGrey)),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _vaccinCard(VaccinationDto vaccin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGreen),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.vaccines, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccin.vaccineName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  vaccin.vaccineType ?? '—',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(vaccin.vaccinationDate),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _healthRecordCard(HealthRecordDto record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: record.recordType == 'DISEASE'
                ? AppColors.danger
                : AppColors.primaryGreen,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.diagnosis ?? _formatRecordType(record.recordType),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (record.treatment != null)
            Text(
              'Traitement : ${record.treatment}',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          Text(
            _formatDate(record.visitDate),
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSuccessCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textGrey),
      ),
    );
  }

  String _formatSpecies(String? species) {
    return {'OVIN': 'Ovin', 'BOVIN': 'Bovin'}[species] ?? species ?? '—';
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
    } catch (_) {
      return dateStr.toString();
    }
  }

  String _formatRecordType(String? type) {
    return {
      'VACCINATION': 'Vaccination',
      'TREATMENT': 'Traitement',
      'DISEASE': 'Maladie',
      'CHECKUP': 'Contrôle',
    }[type] ?? type ?? '—';
  }
}
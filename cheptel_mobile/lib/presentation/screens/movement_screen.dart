import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/movement_provider.dart';

class MovementScreen extends StatefulWidget {
  final int animalId;
  final String animalRfid;

  const MovementScreen({
    super.key,
    required this.animalId,
    required this.animalRfid,
  });

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  final _formKey = GlobalKey<FormState>();

  String _movementType = 'SALE';
  final _priceController = TextEditingController();
  final _counterpartyNameController = TextEditingController();
  final _counterpartyPhoneController = TextEditingController();
  final _documentRefController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovementProvider>(context, listen: false)
          .loadByAnimal(widget.animalId);
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _counterpartyNameController.dispose();
    _counterpartyPhoneController.dispose();
    _documentRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovementProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Mouvements - ${widget.animalRfid}"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCreateForm(provider),
            const SizedBox(height: 24),
            _buildHistorySection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm(MovementProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Ajouter un Mouvement",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _movementType,
              decoration: const InputDecoration(
                labelText: "Type de mouvement",
                prefixIcon: Icon(Icons.swap_horiz),
              ),
              items: const [
                DropdownMenuItem(value: 'SALE', child: Text("Vente")),
                DropdownMenuItem(value: 'TRANSFER', child: Text("Transfert")),
                DropdownMenuItem(value: 'PURCHASE', child: Text("Achat")),
                DropdownMenuItem(value: 'DEATH', child: Text("Décès")),
                DropdownMenuItem(value: 'SLAUGHTER', child: Text("Abattage")),
              ],
              onChanged: (v) => setState(() => _movementType = v!),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Prix (optionnel)",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _counterpartyNameController,
              decoration: const InputDecoration(
                labelText: "Nom de la contrepartie",
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _counterpartyPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Téléphone contrepartie",
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _documentRefController,
              decoration: const InputDecoration(
                labelText: "Référence document",
                prefixIcon: Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notes",
                prefixIcon: Icon(Icons.note),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                  final data = {
                    "animalId": widget.animalId,
                    "movementType": _movementType,
                    "movementDate": DateTime.now().toIso8601String(),
                    "price": double.tryParse(_priceController.text),
                    "counterpartyName": _counterpartyNameController.text.trim(),
                    "counterpartyPhone": _counterpartyPhoneController.text.trim(),
                    "documentReference": _documentRefController.text.trim(),
                    "notes": _notesController.text.trim(),
                  };

                  final success = await provider.createMovement(data);

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.success ?? "Succès"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    provider.loadByAnimal(widget.animalId);
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Enregistrer Mouvement",
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

            if (provider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(MovementProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Historique des Mouvements",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),

          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.movements.isEmpty)
            const Text(
              "Aucun mouvement enregistré",
              style: TextStyle(color: AppColors.textGrey),
            )
          else
            ...provider.movements.map(
                  (m) => Card(
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primaryGreen),
                  title: Text(m.movementType),
                  subtitle: Text(m.movementDate),
                  trailing: m.price != null
                      ? Text("${m.price} DA")
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
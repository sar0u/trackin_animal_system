import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/reproduction_provider.dart';


class ReproductionScreen extends StatefulWidget {
  const ReproductionScreen({super.key});

  @override
  State<ReproductionScreen> createState() => _ReproductionScreenState();
}

class _ReproductionScreenState extends State<ReproductionScreen> {
  final _femaleIdController = TextEditingController();
  final _maleIdController = TextEditingController();
  final _offspringController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'IN_PROGRESS';
  DateTime? _breedingDate;
  DateTime? _expectedBirthDate;

  @override
  void dispose() {
    _femaleIdController.dispose();
    _maleIdController.dispose();
    _offspringController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReproductionProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Suivi Reproductif"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text(
                "Nouvel Enregistrement",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _femaleIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ID Femelle *",
                  prefixIcon: Icon(Icons.female),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _maleIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ID Mâle",
                  prefixIcon: Icon(Icons.male),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: "Statut",
                  prefixIcon: Icon(Icons.info),
                ),
                items: const [
                  DropdownMenuItem(value: 'IN_PROGRESS', child: Text("En cours")),
                  DropdownMenuItem(value: 'SUCCESSFUL', child: Text("Réussi")),
                  DropdownMenuItem(value: 'FAILED', child: Text("Échoué")),
                  DropdownMenuItem(value: 'ABORTED', child: Text("Avorté")),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _breedingDate == null
                      ? "Date d'accouplement"
                      : "Accouplement : ${_breedingDate!.toIso8601String().split('T')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _breedingDate = date);
                },
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _expectedBirthDate == null
                      ? "Date prévue de mise bas"
                      : "Mise bas prévue : ${_expectedBirthDate!.toIso8601String().split('T')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 150)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _expectedBirthDate = date);
                },
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _offspringController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nombre de descendants",
                  prefixIcon: Icon(Icons.family_restroom),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    final data = {
                      "femaleId": int.tryParse(_femaleIdController.text),
                      "maleId": int.tryParse(_maleIdController.text),
                      "breedingDate": _breedingDate?.toIso8601String().split('T')[0],
                      "expectedBirthDate": _expectedBirthDate?.toIso8601String().split('T')[0],
                      "offspringCount": int.tryParse(_offspringController.text),
                      "status": _status,
                      "notes": _notesController.text.trim(),
                    };

                    final success = await provider.createReproduction(data);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.success ?? "Succès"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Enregistrer",
                    style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
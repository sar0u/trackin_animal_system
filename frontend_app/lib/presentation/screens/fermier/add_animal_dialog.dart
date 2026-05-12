import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/fermier_provider.dart';

class AddAnimalDialog extends StatefulWidget {
  const AddAnimalDialog({super.key});

  @override
  State<AddAnimalDialog> createState() => _AddAnimalDialogState();
}

class _AddAnimalDialogState extends State<AddAnimalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rfidController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  String _species = "OVIN";
  String _gender = "MALE";
  DateTime? _birthDate;

  @override
  void dispose() {
    _rfidController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fermierProvider = Provider.of<FermierProvider>(context);

    return AlertDialog(
      title: const Text("Ajouter un Animal"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _rfidController,
                decoration: const InputDecoration(labelText: "Tag RFID *", hintText: "EX: 2024-MA-99999"),
                validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _species,
                decoration: const InputDecoration(labelText: "Espèce *"),
                items: const [
                  DropdownMenuItem(value: "OVIN", child: Text("Ovin (Mouton)")),
                  DropdownMenuItem(value: "BOVIN", child: Text("Bovin (Vache)")),
                ],
                onChanged: (v) => setState(() => _species = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: "Race"),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: "Sexe"),
                items: const [
                  DropdownMenuItem(value: "MALE", child: Text("Mâle")),
                  DropdownMenuItem(value: "FEMALE", child: Text("Femelle")),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Poids (kg)"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: "Couleur"),
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? "Date de naissance"
                      : "Né le : ${_birthDate!.toIso8601String().split('T')[0]}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365)),
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _birthDate = date);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: fermierProvider.isLoading
              ? null
              : () async {
            if (!_formKey.currentState!.validate()) return;

            final data = {
              "rfidTag": _rfidController.text.trim(),
              "species": _species,
              "breed": _breedController.text.trim(),
              "gender": _gender,
              "weight": double.tryParse(_weightController.text) ?? 0,
              "color": _colorController.text.trim(),
              "birthDate": _birthDate?.toIso8601String().split('T')[0],
            };

            bool success = await fermierProvider.createAnimal(data);
            if (success && mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Animal ajouté !"), backgroundColor: Colors.green),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          child: const Text("Créer", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
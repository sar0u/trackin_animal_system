import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/animal_model.dart';
import '../providers/fermier_provider.dart';

class EditAnimalDialog extends StatefulWidget {
  final AnimalModel animal;

  const EditAnimalDialog({super.key, required this.animal});

  @override
  State<EditAnimalDialog> createState() => _EditAnimalDialogState();
}

class _EditAnimalDialogState extends State<EditAnimalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _colorController;

  late String _gender;
  late String _status;

  @override
  void initState() {
    super.initState();
    _breedController = TextEditingController(text: widget.animal.breed ?? '');
    _weightController = TextEditingController(text: widget.animal.weight?.toString() ?? '');
    _colorController = TextEditingController(text: widget.animal.color ?? '');
    _gender = widget.animal.gender ?? 'MALE';
    _status = widget.animal.status;
  }

  @override
  void dispose() {
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fermierProvider = Provider.of<FermierProvider>(context);

    return AlertDialog(
      title: Text("Modifier ${widget.animal.rfidTag}"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: "Race"),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _gender,
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

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Statut"),
                items: const [
                  DropdownMenuItem(value: "ACTIVE", child: Text("Actif")),
                  DropdownMenuItem(value: "SOLD", child: Text("Vendu")),
                  DropdownMenuItem(value: "QUARANTINED", child: Text("Quarantaine")),
                  DropdownMenuItem(value: "LOST", child: Text("Perdu")),
                  DropdownMenuItem(value: "DEAD", child: Text("Décédé")),
                  DropdownMenuItem(value: "SLAUGHTERED", child: Text("Abattu")),
                ],
                onChanged: (v) => setState(() => _status = v!),
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
              "breed": _breedController.text.trim(),
              "gender": _gender,
              "weight": double.tryParse(_weightController.text),
              "color": _colorController.text.trim(),
              "status": _status,
            };

            bool success = await fermierProvider.updateAnimal(
              widget.animal.id,
              data,
            );

            if (success && mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Animal modifié avec succès"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          child: const Text("Modifier", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
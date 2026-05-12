import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/veterinaire_provider.dart';


class AddVaccinationDialog extends StatefulWidget {
  final String rfidTag;

  const AddVaccinationDialog({super.key, required this.rfidTag});

  @override
  State<AddVaccinationDialog> createState() => _AddVaccinationDialogState();
}

class _AddVaccinationDialogState extends State<AddVaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _vaccineTypeController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchController = TextEditingController();
  DateTime? _vaccinationDate;
  DateTime? _expirationDate;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VeterinaireProvider>(context);

    return AlertDialog(
      title: const Text("Nouvelle Vaccination"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(labelText: "Nom du vaccin *"),
                validator: (v) => v!.isEmpty ? "Obligatoire" : null,
              ),
              TextFormField(
                controller: _vaccineTypeController,
                decoration: const InputDecoration(labelText: "Type de vaccin"),
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: "Fabricant"),
              ),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: "Numéro de lot"),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_vaccinationDate == null
                    ? "Date de vaccination"
                    : "Vacciné le: ${_vaccinationDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _vaccinationDate = date);
                },
              ),
              ListTile(
                title: Text(_expirationDate == null
                    ? "Date d'expiration"
                    : "Expire le: ${_expirationDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (date != null) setState(() => _expirationDate = date);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: provider.isLoading
              ? null
              : () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                "vaccineName": _vaccineNameController.text,
                "vaccineType": _vaccineTypeController.text,
                "manufacturer": _manufacturerController.text,
                "batchNumber": _batchController.text,
                "vaccinationDate": _vaccinationDate?.toIso8601String().split('T')[0],
                "expirationDate": _expirationDate?.toIso8601String().split('T')[0],
              };

              bool success = await provider.addVaccination(widget.rfidTag, data);
              if (success && mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/veterinaire_provider.dart';


class AddHealthRecordDialog extends StatefulWidget {
  final String rfidTag;

  const AddHealthRecordDialog({super.key, required this.rfidTag});

  @override
  State<AddHealthRecordDialog> createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _treatmentController = TextEditingController();
  String _recordType = "Treatment";
  DateTime? _visitDate;
  DateTime? _nextVisitDate;
  String? _errorMsg;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VeterinaireProvider>(context);

    return AlertDialog(
      title: const Text("Nouvelle Consultation"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _recordType,
                decoration: const InputDecoration(labelText: "Type"),
                items: const [
                  DropdownMenuItem(value: "Treatment",  child: Text("Traitement")),
                  DropdownMenuItem(value: "Disease",    child: Text("Maladie")),
                  DropdownMenuItem(value: "Checkup",    child: Text("Contrôle")),
                  DropdownMenuItem(value: "Surgery",    child: Text("Chirurgie")),
                  DropdownMenuItem(value: "Injury",     child: Text("Blessure")),
                  DropdownMenuItem(value: "LabTest",    child: Text("Analyse de labo")),
                  DropdownMenuItem(value: "Vaccination",child: Text("Vaccination")),
                ],
                onChanged: (val) => setState(() => _recordType = val!),
              ),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(labelText: "Diagnostic *"),
                validator: (v) => v!.isEmpty ? "Obligatoire" : null,
              ),
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(labelText: "Symptômes"),
              ),
              TextFormField(
                controller: _treatmentController,
                decoration: InputDecoration(
                  labelText: _recordType == 'Checkup' ? "Traitement" : "Traitement *",
                ),
                validator: (v) =>
                    _recordType != 'Checkup' && (v == null || v.isEmpty)
                        ? "Obligatoire"
                        : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_visitDate == null ? "Date de la visite" : "Visite le: ${_visitDate!.toLocal().toString().split(' ')[0]}"),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (date != null) setState(() => _visitDate = date);
                },
              ),
              ListTile(
                title: Text(_nextVisitDate == null ? "Prochain contrôle" : "Prochain le: ${_nextVisitDate!.toLocal().toString().split(' ')[0]}"),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2035));
                  if (date != null) setState(() => _nextVisitDate = date);
                },
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
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
                "recordType": _recordType,
                "diagnosis": _diagnosisController.text,
                "symptoms": _symptomsController.text,
                "treatment": _treatmentController.text.isEmpty ? null : _treatmentController.text,
                "visitDate": _visitDate != null ? '${_visitDate!.toIso8601String().split('T')[0]}T00:00:00' : null,
                "nextVisitDate": _nextVisitDate != null ? '${_nextVisitDate!.toIso8601String().split('T')[0]}T00:00:00' : null,
              };

              final success = await provider.addHealthRecord(widget.rfidTag, data);
              if (!mounted) return;
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Consultation enregistrée avec succès"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                setState(() {
                  _errorMsg = provider.error ?? "Erreur lors de l'enregistrement";
                });
              }
            }
          },
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
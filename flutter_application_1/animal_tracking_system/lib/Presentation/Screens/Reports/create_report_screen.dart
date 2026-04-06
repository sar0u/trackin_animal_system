import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../../Core/Utils/validators.dart';
import '../../Widgets/Common/custom_button.dart';
import '../../Widgets/Common/custom_text_field.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _reportType = 'Fraud';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Envoyer rapport via API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport envoyé')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'createReport'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _reportType,
                items: const [
                  DropdownMenuItem(value: 'Fraud', child: Text('Fraude')),
                  DropdownMenuItem(value: 'IllegalSale', child: Text('Vente Illégale')),
                  DropdownMenuItem(value: 'HealthIssue', child: Text('Problème Santé')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _reportType = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Type de Rapport'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 5,
                validator: (value) => Validators.validateRequired(value, 'la description'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Envoyer Rapport',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
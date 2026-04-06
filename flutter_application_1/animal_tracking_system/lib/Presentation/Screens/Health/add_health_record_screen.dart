import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../../Core/Utils/validators.dart';
import '../../Widgets/Common/custom_button.dart';
import '../../Widgets/Common/custom_text_field.dart';

class AddHealthRecordScreen extends StatefulWidget {
  const AddHealthRecordScreen({super.key});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Ajouter registre via API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre de santé ajouté')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'addHealthRecord'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _typeController,
                label: 'Type (ex: Vaccin, Contrôle)',
                validator: (value) => Validators.validateRequired(value, 'le type'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) => Validators.validateRequired(value, 'la description'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: 'Notes',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Ajouter Registre',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
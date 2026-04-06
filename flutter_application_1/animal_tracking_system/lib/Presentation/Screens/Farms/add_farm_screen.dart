import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../../Core/Utils/validators.dart';
import '../../Widgets/Common/custom_button.dart';
import '../../Widgets/Common/custom_text_field.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Ajouter ferme via API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ferme ajoutée avec succès')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'addFarm'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nom de la Ferme',
                validator: (value) => Validators.validateRequired(value, 'le nom'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Localisation',
                validator: (value) => Validators.validateRequired(value, 'la localisation'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _capacityController,
                label: 'Capacité (animaux)',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateNumber(value, 'la capacité'),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: AppTranslations.translate(context, 'addFarm'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
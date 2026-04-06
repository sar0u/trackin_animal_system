import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../../Core/Utils/validators.dart';
import '../../Widgets/Common/custom_button.dart';
import '../../Widgets/Common/custom_text_field.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _rfidController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Appeler API pour ajouter l'animal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.translate(context, 'addAnimal') + ' ajouté avec succès')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'addAnimal'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nom de l\'Animal',
                validator: (value) => Validators.validateRequired(value, 'le nom'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _breedController,
                label: 'Race',
                validator: (value) => Validators.validateRequired(value, 'la race'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ageController,
                label: 'Âge (en années)',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateNumber(value, 'l\'âge'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _weightController,
                label: 'Poids (kg)',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateNumber(value, 'le poids'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _rfidController,
                label: 'ID RFID',
                validator: (value) => Validators.validateRequired(value, 'l\'ID RFID'),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: AppTranslations.translate(context, 'addAnimal'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
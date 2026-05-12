import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = "FERMIER";

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte"), backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: AppColors.primaryGreen),
                const SizedBox(height: 16),
                const Text(
                  "Inscription",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Username
                _buildTextField(
                  controller: _usernameController,
                  label: "Nom d'utilisateur",
                  icon: Icons.person,
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Obligatoire";
                    if (!v.contains('@')) return "Email invalide";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Téléphone
                _buildTextField(
                  controller: _phoneController,
                  label: "Numéro de téléphone",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? "Obligatoire" : null,
                ),
                const SizedBox(height: 16),

                // Rôle
                const Text("Choisissez votre rôle", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: "FERMIER", child: Text("Fermier (Éleveur)")),
                        DropdownMenuItem(value: "VETERINAIRE", child: Text("Vétérinaire")),
                        DropdownMenuItem(value: "CONTROLEUR", child: Text("Contrôleur (Agent)")),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mot de passe
                _buildTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  icon: Icons.lock,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Obligatoire";
                    if (v.length < 6) return "Au moins 6 caractères";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirmation
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirmer le mot de passe",
                  icon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) {
                    if (v != _passwordController.text) return "Les mots de passe ne correspondent pas";
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      bool success = await auth.register(
                        username: _usernameController.text.trim(),
                        email: _emailController.text.trim(),
                        phoneNumber: _phoneController.text.trim(),
                        password: _passwordController.text.trim(),
                        role: _selectedRole,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Compte créé avec succès !"), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CRÉER MON COMPTE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }
}
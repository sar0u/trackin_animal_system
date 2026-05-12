import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;

  final _contactController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Réinitialisation"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 24),

              if (_step == 1) _buildStepContact(auth),
              if (_step == 2) _buildStepCode(auth),
              if (_step == 3) _buildStepNewPassword(auth),

              if (auth.error != null) ...[
                const SizedBox(height: 16),
                _messageBox(auth.error!, true),
              ],

              if (auth.success != null) ...[
                const SizedBox(height: 16),
                _messageBox(auth.success!, false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final active = index + 1 <= _step;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.primaryGreen : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContact(AuthProvider auth) {
    return Column(
      children: [
        const Icon(Icons.lock_reset, size: 80, color: AppColors.primaryGreen),
        const SizedBox(height: 16),
        const Text(
          "Mot de passe oublié",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Entrez votre email ou numéro de téléphone.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _contactController,
          decoration: const InputDecoration(
            labelText: "Email ou téléphone",
            prefixIcon: Icon(Icons.contact_mail),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
              final contact = _contactController.text.trim();

              if (contact.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Veuillez saisir un email ou téléphone"),
                  ),
                );
                return;
              }

              final ok = await auth.forgotPassword(contact);

              if (ok && mounted) {
                auth.clearMessages();
                setState(() => _step = 2);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: auth.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "ENVOYER LE CODE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "En développement, le code est aussi affiché dans la console du backend.",
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCode(AuthProvider auth) {
    return Column(
      children: [
        const Icon(Icons.verified_user, size: 80, color: AppColors.primaryGreen),
        const SizedBox(height: 16),
        const Text(
          "Validation du code",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Saisissez le code à 6 chiffres.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _codeController,
          maxLength: 6,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: "000000",
            counterText: "",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
              final contact = _contactController.text.trim();
              final code = _codeController.text.trim();

              if (code.length != 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Code invalide"),
                  ),
                );
                return;
              }

              final ok = await auth.verifyResetCode(contact, code);

              if (ok && mounted) {
                auth.clearMessages();
                setState(() => _step = 3);
              }
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: auth.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "VALIDER LE CODE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
          ),
        ),

        TextButton(
          onPressed: auth.isLoading
              ? null
              : () async {
            await auth.forgotPassword(_contactController.text.trim());
          },
          child: const Text("Renvoyer le code"),
        ),
      ],
    );
  }

  Widget _buildStepNewPassword(AuthProvider auth) {
    return Column(
      children: [
        const Icon(Icons.lock_open, size: 80, color: AppColors.primaryGreen),
        const SizedBox(height: 16),
        const Text(
          "Nouveau mot de passe",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Nouveau mot de passe",
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Confirmer le mot de passe",
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () async {
              final pass = _newPasswordController.text.trim();
              final confirm = _confirmPasswordController.text.trim();

              if (pass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Minimum 6 caractères"),
                  ),
                );
                return;
              }

              if (pass != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Les mots de passe ne correspondent pas"),
                  ),
                );
                return;
              }

              final ok = await auth.resetPassword(
                _contactController.text.trim(),
                _codeController.text.trim(),
                pass,
              );

              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mot de passe réinitialisé"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: auth.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "RÉINITIALISER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _messageBox(String text, bool error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFEBEE) : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: error ? AppColors.danger : AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


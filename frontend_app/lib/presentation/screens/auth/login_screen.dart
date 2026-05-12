import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const SizedBox(height: 30),

                // ========================
                // LOGO
                // ========================
                Image.asset(
                  'assets/launcher_icon/icon.png',
                  width: 90,
                  height: 90,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.agriculture,
                    size: 90,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "DZcheptel",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Gestion intelligente du cheptel",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 40),

                // ========================
                // IDENTIFIANT / EMAIL
                // ========================
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: "Identifiant ou Email",
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Champ obligatoire"
                      : null,
                ),

                const SizedBox(height: 18),

                // ========================
                // PASSWORD
                // ========================
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? "Champ obligatoire"
                      : null,
                ),

                // ========================
                // MOT DE PASSE OUBLIÉ
                // ========================
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                // ========================
                // OPTION RESTER CONNECTÉ
                // ========================
                Row(
                  children: [
                    Checkbox(
                      value: auth.rememberMe,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        auth.setRememberMe(val ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Rester connecté sur cet appareil",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                // ========================
                // OPTION ACCEPTER CONDITIONS
                // ========================
                Row(
                  children: [
                    Checkbox(
                      value: auth.acceptTerms,
                      activeColor: AppColors.primaryGreen,
                      onChanged: (val) =>
                          auth.setAcceptTerms(val ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showTermsDialog(context),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "J'accepte les "),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ========================
                // SE CONNECTER
                // ========================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (!auth.acceptTerms) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Veuillez accepter les conditions"),
                          ),
                        );
                        return;
                      }

                      bool success = await auth.login(
                        _identifierController.text.trim(),
                        _passwordController.text.trim(),
                      );

                      if (success && mounted) {
                        _navigateToHome(
                            context, auth.user!.role);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text(
                      "SE CONNECTER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ========================
                // CRÉER UN COMPTE
                // ========================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add,
                      color: AppColors.primaryGreen,
                    ),
                    label: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                if (auth.error != null)
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 16),
                    child: Container(
                      padding:
                      const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Text(
                        auth.error!,
                        style: const TextStyle(
                            color: Colors.red),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                const Divider(),
                const SizedBox(height: 12),

                const Text(
                  "MINISTÈRE DE L'AGRICULTURE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // DIALOG CONDITIONS EN LISTE À TIRETS
  // ========================================
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text("Conditions d'utilisation"),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "En utilisant cette application, vous acceptez les conditions suivantes :",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 14),

              _BulletItem(
                "Vos données personnelles sont protégées conformément à la réglementation.",
              ),
              _BulletItem(
                "Toute fausse déclaration est passible de poursuites judiciaires.",
              ),
              _BulletItem(
                "Les informations enregistrées sont utilisées uniquement pour la gestion et la traçabilité du cheptel national.",
              ),
              _BulletItem(
                "Vous êtes responsable de la confidentialité de vos identifiants.",
              ),
              _BulletItem(
                "Le système peut être audité par les autorités compétentes à tout moment.",
              ),
              _BulletItem(
                "Le ministère de l'Agriculture se réserve le droit de suspendre tout compte en cas d'usage frauduleux.",
              ),

              SizedBox(height: 14),
              Text(
                "En cochant la case, vous reconnaissez avoir lu et accepté ces conditions.",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context, String role) {
    switch (role) {
      case 'FERMIER':
        Navigator.pushReplacementNamed(context, '/fermier');
        break;
      case 'VETERINAIRE':
        Navigator.pushReplacementNamed(context, '/veterinaire');
        break;
      case 'CONTROLEUR':
        Navigator.pushReplacementNamed(context, '/controleur');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// ========================================
// WIDGET POUR LES TIRETS DES CONDITIONS
// ========================================
class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "—",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
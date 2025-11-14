import 'package:flutter/material.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/register_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';

/// Page de connexion de l'application
/// Permet à un utilisateur existant de se connecter
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour récupérer le texte des champs
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // Services nécessaires
  final _databaseHelper = DatabaseHelper();
  final _authService = AuthService();

  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  // Variable pour afficher un indicateur de chargement
  bool _isLoading = false;

  // Variable pour masquer/afficher le mot de passe
  bool _obscurePassword = true;

  /// Libérer les ressources quand la page est détruite
  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  /// Fonction de connexion
  /// Vérifie les identifiants et connecte l'utilisateur si correct
  Future<void> _creerConnexion() async {
    // Valider le formulaire (vérifier que les champs sont corrects)
    if (!_formKey.currentState!.validate()) return;

    // Afficher l'indicateur de chargement
    setState(() => _isLoading = true);

    try {
      // Appeler la fonction de connexion de la base de données
      final result = await _databaseHelper.loginUser(
        email: _emailController.text.trim(),
        password: _motDePasseController.text,
      );

      // Vérifier que le widget existe toujours
      if (!mounted) return;

      // Si la connexion est réussie
      if (result['success']) {
        // Sauvegarder la session de l'utilisateur
        await _authService.saveUserSession(result['user']);

        // Naviguer vers la page d'accueil (remplacer l'écran actuel)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur inattendue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Cacher l'indicateur de chargement
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond blanc
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de l'application
                  SizedBox(
                     height: 200,
                     child: Image.asset("assets/images/logo.png"),
                    ),
                  // Titre "Connexion"
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Champ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Écrivez votre adresse email",
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 211, 137, 100),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Validation du champ email
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Champ Mot de passe
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: _obscurePassword, // Masquer le texte
                    decoration: InputDecoration(
                      hintText: "Écrivez votre mot de passe",
                      prefixIcon: Icon(Icons.lock_outlined),
                      // Bouton pour afficher/masquer le mot de passe
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
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
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 211, 137, 100),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Validation du mot de passe
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Bouton "Se connecter"
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _creerConnexion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        backgroundColor: const Color.fromRGBO(0, 211, 137, 100),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(width: 2, color: Colors.black),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Bouton "Créer un compte"
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        // Naviguer vers la page d'inscription
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        backgroundColor: const Color.fromRGBO(
                          118,
                          189,
                          255,
                          100,
                        ),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(width: 2, color: Colors.black),
                      ),
                      child: Text(
                        "Créer un compte",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

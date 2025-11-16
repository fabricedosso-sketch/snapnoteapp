import 'package:flutter/material.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/register_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';

// ==============================================================================
// PAGE DE CONNEXION
// ==============================================================================
// Cette page permet à un utilisateur existant de se connecter à l'application
// Elle demande l'email et le mot de passe, puis vérifie dans la base de données
// C'est comme la porte d'entrée avec un code d'accès !
// ==============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ==============================================================================
// ÉTAT DE LA PAGE DE CONNEXION
// ==============================================================================
// Cette classe gère tout ce qui peut changer sur la page
// (texte saisi, chargement, visibilité du mot de passe, etc.)
// ==============================================================================
class _LoginScreenState extends State<LoginScreen> {
  // ==========================================================================
  // CONTRÔLEURS DE CHAMPS DE TEXTE
  // ==========================================================================
  // Les contrôleurs permettent de récupérer ce que l'utilisateur tape
  // C'est comme avoir un carnet pour noter ce qu'on dit !
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // ==========================================================================
  // SERVICES NÉCESSAIRES
  // ==========================================================================
  // DatabaseHelper = pour vérifier les identifiants dans la base de données
  // AuthService = pour gérer la session de connexion
  final _databaseHelper = DatabaseHelper();
  final _authService = AuthService();

  // ==========================================================================
  // CLÉ DE VALIDATION DU FORMULAIRE
  // ==========================================================================
  // Cette clé permet de vérifier que tous les champs sont correctement remplis
  // avant de tenter la connexion
  final _formKey = GlobalKey<FormState>();

  // ==========================================================================
  // VARIABLES D'ÉTAT
  // ==========================================================================
  // _isLoading = true quand on est en train de vérifier les identifiants
  // Permet d'afficher un spinner et de désactiver le bouton
  bool _isLoading = false;

  // _obscurePassword = true pour masquer le mot de passe (afficher des points)
  // L'utilisateur peut cliquer sur l'œil pour le voir/cacher
  bool _obscurePassword = true;

  // ==========================================================================
  // NETTOYAGE DES RESSOURCES
  // ==========================================================================
  // Cette fonction est appelée quand la page est détruite
  // Elle libère la mémoire utilisée par les contrôleurs
  // C'est comme ranger ses affaires avant de quitter une pièce !
  // ==========================================================================
  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // FONCTION DE CONNEXION
  // ==========================================================================
  // Cette fonction est appelée quand on clique sur "Se connecter"
  // Elle vérifie les identifiants et connecte l'utilisateur si tout est correct
  // ==========================================================================
  Future<void> _creerConnexion() async {
    // ========================================================================
    // VALIDATION DU FORMULAIRE
    // ========================================================================
    // validate() vérifie tous les champs avec leurs validator()
    // Si un champ est invalide, ça retourne false et affiche l'erreur
    if (!_formKey.currentState!.validate()) return;

    // ========================================================================
    // AFFICHER L'INDICATEUR DE CHARGEMENT
    // ========================================================================
    // setState() = dire à Flutter de redessiner l'interface
    // On met _isLoading à true pour montrer le spinner
    setState(() => _isLoading = true);

    try {
      // ======================================================================
      // VÉRIFIER LES IDENTIFIANTS DANS LA BASE DE DONNÉES
      // ======================================================================
      // loginUser() cherche dans la base un utilisateur avec cet email
      // et ce mot de passe, puis retourne un Map avec le résultat
      final result = await _databaseHelper.loginUser(
        email: _emailController.text.trim(), // trim() enlève les espaces
        password: _motDePasseController.text,
      );

      // ======================================================================
      // VÉRIFIER QUE LE WIDGET EXISTE TOUJOURS
      // ======================================================================
      // mounted = vérifie que la page n'a pas été fermée pendant l'attente
      if (!mounted) return;

      // ======================================================================
      // TRAITER LE RÉSULTAT
      // ======================================================================
      if (result['success']) {
        // ====================================================================
        // CONNEXION RÉUSSIE
        // ====================================================================
        // Les identifiants sont corrects !
        
        // Sauvegarder la session de l'utilisateur
        // Cela permet de le garder connecté
        await _authService.saveUserSession(result['user']);

        // Naviguer vers la page d'accueil
        // pushReplacement = remplacer la page actuelle (pas de retour possible)
        // On ne veut pas que l'utilisateur puisse revenir à la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // ====================================================================
        // CONNEXION ÉCHOUÉE
        // ====================================================================
        // Email ou mot de passe incorrect
        
        // Afficher le message d'erreur en bas de l'écran
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.redAccent, // Rouge = erreur
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ======================================================================
      // GESTION DES ERREURS INATTENDUES
      // ======================================================================
      // Si quelque chose se passe mal, on affiche l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // ======================================================================
      // CACHER L'INDICATEUR DE CHARGEMENT
      // ======================================================================
      // finally = toujours exécuté, que ça marche ou pas
      // On vérifie mounted avant de faire setState()
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================================================
  // CONSTRUCTION DE L'INTERFACE VISUELLE
  // ==========================================================================
  // Cette fonction crée tout ce qu'on voit à l'écran
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond blanc
      backgroundColor: Colors.white,
      
      body: SafeArea(
        // SafeArea évite que le contenu soit caché par l'encoche
        child: Center(
          // Center = centrer tout le contenu
          child: SingleChildScrollView(
            // Permet de défiler si le clavier apparaît ou sur petit écran
            padding: EdgeInsets.all(30),
            
            // ================================================================
            // FORMULAIRE
            // ================================================================
            // Form permet de grouper les champs et de les valider ensemble
            child: Form(
              key: _formKey, // La clé pour accéder au formulaire
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ==============================================================
                  // LOGO DE L'APPLICATION
                  // ==============================================================
                  SizedBox(
                    height: 200,
                    child: Image.asset("assets/images/logo.png"),
                  ),
                  
                  // ==============================================================
                  // TITRE "CONNEXION"
                  // ==============================================================
                  Text(
                    "Connexion",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900, // Très gras
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),

                  // ==============================================================
                  // CHAMP EMAIL
                  // ==============================================================
                  TextFormField(
                    controller: _emailController, // Contrôleur pour récupérer le texte
                    keyboardType: TextInputType.emailAddress, // Clavier avec @
                    decoration: InputDecoration(
                      hintText: "Écrivez votre adresse email", // Texte indicatif
                      prefixIcon: Icon(Icons.email_outlined), // Icône à gauche
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // Style quand le champ est sélectionné
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(0, 211, 137, 100), // Vert
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // ============================================================
                    // VALIDATION DE L'EMAIL
                    // ============================================================
                    // Cette fonction vérifie que l'email est correct
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null; // null = pas d'erreur
                    },
                  ),
                  SizedBox(height: 20),

                  // ==============================================================
                  // CHAMP MOT DE PASSE
                  // ==============================================================
                  TextFormField(
                    controller: _motDePasseController,
                    obscureText: _obscurePassword, // Masquer le texte (points)
                    decoration: InputDecoration(
                      hintText: "Écrivez votre mot de passe",
                      prefixIcon: Icon(Icons.lock_outlined),
                      // ========================================================
                      // BOUTON POUR VOIR/CACHER LE MOT DE PASSE
                      // ========================================================
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined // Œil ouvert
                              : Icons.visibility_off_outlined, // Œil barré
                        ),
                        onPressed: () {
                          // Inverser l'état de visibilité
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
                    // ============================================================
                    // VALIDATION DU MOT DE PASSE
                    // ============================================================
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

                  // ==============================================================
                  // BOUTON "SE CONNECTER"
                  // ==============================================================
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      // Si _isLoading est true, le bouton est désactivé (null)
                      onPressed: _isLoading ? null : _creerConnexion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        backgroundColor: const Color.fromRGBO(0, 211, 137, 100),
                        foregroundColor: Colors.black, // Couleur du texte
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(width: 2, color: Colors.black),
                      ),
                      // ========================================================
                      // CONTENU DU BOUTON
                      // ========================================================
                      // Si _isLoading : afficher un spinner
                      // Sinon : afficher le texte "Se connecter"
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

                  // ==============================================================
                  // BOUTON "CRÉER UN COMPTE"
                  // ==============================================================
                  // Pour les utilisateurs qui n'ont pas encore de compte
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
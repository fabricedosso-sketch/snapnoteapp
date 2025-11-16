import 'package:flutter/material.dart';
import 'package:projetfinal/model/users_model.dart';
import 'package:projetfinal/screens/home_screen.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';

// ==============================================================================
// PAGE D'INSCRIPTION
// ==============================================================================
// Cette page permet à un nouvel utilisateur de créer un compte
// Elle collecte : nom, prénom, email et mot de passe
// C'est comme remplir un formulaire d'adhésion à un club !
// ==============================================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// ==============================================================================
// ÉTAT DE LA PAGE D'INSCRIPTION
// ==============================================================================
// Cette classe gère tout ce qui peut changer sur la page
// (texte saisi, chargement, visibilité du mot de passe, etc.)
// ==============================================================================
class _RegisterScreenState extends State<RegisterScreen> {
  // ==========================================================================
  // CONTRÔLEURS DE CHAMPS DE TEXTE
  // ==========================================================================
  // Les contrôleurs permettent de récupérer ce que l'utilisateur tape
  // C'est comme avoir un carnet pour noter ce qu'on dit !
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  // ==========================================================================
  // SERVICES NÉCESSAIRES
  // ==========================================================================
  // DatabaseHelper = pour enregistrer le nouvel utilisateur dans la base
  // AuthService = pour gérer la session de connexion
  final _databaseHelper = DatabaseHelper();
  final _authService = AuthService();

  // ==========================================================================
  // CLÉ DE VALIDATION DU FORMULAIRE
  // ==========================================================================
  // Cette clé permet de vérifier que tous les champs sont correctement remplis
  // avant de créer le compte
  final _formKey = GlobalKey<FormState>();

  // ==========================================================================
  // VARIABLES D'ÉTAT
  // ==========================================================================
  // _isLoading = true quand on est en train de créer le compte
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
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // FONCTION DE CRÉATION DE COMPTE
  // ==========================================================================
  // Cette fonction est appelée quand on clique sur "Créer un compte"
  // Elle valide les données, crée l'utilisateur, et le connecte automatiquement
  // ==========================================================================
  Future<void> _creerCompte() async {
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
      // CRÉER L'OBJET USER
      // ======================================================================
      // On crée un objet User avec les informations saisies
      // trim() enlève les espaces au début et à la fin du texte
      final user = User(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _motDePasseController.text,
      );

      // ======================================================================
      // ENREGISTRER L'UTILISATEUR DANS LA BASE DE DONNÉES
      // ======================================================================
      // registerUser() crée le compte et retourne un Map avec le résultat
      final result = await _databaseHelper.registerUser(user);

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
        // INSCRIPTION RÉUSSIE
        // ====================================================================
        
        // Sauvegarder la session de l'utilisateur
        // Cela permet de le garder connecté
        await _authService.saveUserSession(result['user']);

        // Afficher un message de succès en bas de l'écran
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green, // Vert = succès
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Naviguer vers la page d'accueil
        // pushReplacement = remplacer la page actuelle (pas de retour possible)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // ====================================================================
        // INSCRIPTION ÉCHOUÉE
        // ====================================================================
        // Par exemple : email déjà utilisé
        
        // Afficher le message d'erreur
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
                  // TITRE "INSCRIPTION"
                  // ==============================================================
                  Text(
                    "Inscription",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900, // Très gras
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),

                  // ==============================================================
                  // CHAMP NOM
                  // ==============================================================
                  TextFormField(
                    controller: _nomController, // Contrôleur pour récupérer le texte
                    decoration: InputDecoration(
                      hintText: "Écrivez votre nom", // Texte indicatif
                      prefixIcon: Icon(Icons.person_outlined), // Icône à gauche
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
                    // VALIDATION DU NOM
                    // ============================================================
                    // Cette fonction vérifie que le nom est valide
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      if (value.length < 2) {
                        return 'Le nom doit contenir au moins 2 caractères';
                      }
                      return null; // null = pas d'erreur
                    },
                  ),
                  SizedBox(height: 20),

                  // ==============================================================
                  // CHAMP PRÉNOM
                  // ==============================================================
                  TextFormField(
                    controller: _prenomController,
                    decoration: InputDecoration(
                      hintText: "Écrivez votre prénom",
                      prefixIcon: Icon(Icons.person_outlined),
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
                    // VALIDATION DU PRÉNOM
                    // ============================================================
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom';
                      }
                      if (value.length < 2) {
                        return 'Le prénom doit contenir au moins 2 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // ==============================================================
                  // CHAMP EMAIL
                  // ==============================================================
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress, // Clavier avec @
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
                    // ============================================================
                    // VALIDATION DE L'EMAIL
                    // ============================================================
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
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 50),

                  // ==============================================================
                  // BOUTON "CRÉER UN COMPTE"
                  // ==============================================================
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      // Si _isLoading est true, le bouton est désactivé (null)
                      onPressed: _isLoading ? null : _creerCompte,
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
                      // Sinon : afficher le texte "Créer un compte"
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
                              "Créer un compte",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // ==============================================================
                  // BOUTON "SE CONNECTER"
                  // ==============================================================
                  // Pour les utilisateurs qui ont déjà un compte
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: () {
                        // Naviguer vers la page de connexion
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
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
                        "Se connecter",
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
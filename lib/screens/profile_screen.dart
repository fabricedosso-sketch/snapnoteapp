import 'package:flutter/material.dart';
import 'package:projetfinal/model/users_model.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

/// Page de profil de l'utilisateur
/// Affiche les informations personnelles avec possibilité de modification
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Utilisateur actuel
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Charger les données de l'utilisateur depuis la base
  Future<void> _loadUserData() async {
    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      final user = await _databaseHelper.getUserById(userId);
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  // ===========================================================================
  //  AFFICHER LE MENU DE MODIFICATION COMPLET
  // ===========================================================================
  // Cette fonction affiche un grand formulaire où on peut modifier TOUTES
  // les informations de l'utilisateur en même temps !
  // C'est comme ouvrir une fenêtre d'édition complète 
  // ===========================================================================
  Future<void> _showEditAllDialog() async {
    // Si pas d'utilisateur, on ne fait rien
    if (_currentUser == null) return;

    // =========================================================================
    // 🎮 CONTRÔLEURS POUR LES CHAMPS DE TEXTE
    // =========================================================================
    // Un contrôleur = un gestionnaire pour un champ de texte
    // Il permet de lire et modifier le contenu du champ
    final nomController = TextEditingController(text: _currentUser!.nom);
    final prenomController = TextEditingController(text: _currentUser!.prenom);
    final emailController = TextEditingController(text: _currentUser!.email);
    
    // Clé pour valider le formulaire (vérifier que tout est correct)
    final formKey = GlobalKey<FormState>();

    // =========================================================================
    // 🎨 AFFICHER LA BOÎTE DE DIALOGUE
    // =========================================================================
    // showDialog = afficher une fenêtre pop-up par-dessus l'écran actuel
    final result = await showDialog<bool>(
      context: context,
      // barrierDismissible = peut-on fermer en cliquant à côté ?
      barrierDismissible: false, // false = on DOIT cliquer sur un bouton
      builder: (context) => AlertDialog(
        // Forme de la boîte avec coins arrondis
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // Titre de la boîte
        title: Row(
          children: [
            Icon(Icons.edit, color: Color.fromRGBO(0, 211, 137, 100)),
            SizedBox(width: 8),
            Text(
              'Modifier mes informations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // =====================================================================
        // CONTENU DU FORMULAIRE
        // =====================================================================
        content: SingleChildScrollView(
          // SingleChildScrollView = permet de faire défiler si trop long
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prendre le minimum d'espace
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // SECTION : INFORMATION PERSONNELLE
                // =============================================================
                Text(
                  'Information personnelle',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                
                // =============================================================
                // 👤 CHAMP NOM
                // =============================================================
                TextFormField(
                  controller: nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 211, 137, 100),
                        width: 2,
                      ),
                    ),
                  ),
                  // Validation : le nom ne doit pas être vide
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom ne peut pas être vide';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit avoir au moins 2 caractères';
                    }
                    return null; // null = tout est OK
                  },
                ),
                SizedBox(height: 16),
                
                // =============================================================
                // CHAMP PRÉNOM
                // =============================================================
                TextFormField(
                  controller: prenomController,
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 211, 137, 100),
                        width: 2,
                      ),
                    ),
                  ),
                  // Validation : le prénom ne doit pas être vide
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le prénom ne peut pas être vide';
                    }
                    if (value.length < 2) {
                      return 'Le prénom doit avoir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                // =============================================================
                // SECTION : ADRESSE EMAIL
                // =============================================================
                Text(
                  'Adresse',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                
                // =============================================================
                // CHAMP EMAIL
                // =============================================================
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 211, 137, 100),
                        width: 2,
                      ),
                    ),
                  ),
                  // Validation : l'email doit être valide
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email ne peut pas être vide';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        
        // =====================================================================
        // BOUTONS D'ACTION
        // =====================================================================
        actions: [
          // ===================================================================
          // BOUTON ANNULER
          // ===================================================================
          TextButton(
            onPressed: () {
              // Fermer la boîte sans sauvegarder
              Navigator.pop(context, false);
            },
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          
          // ===================================================================
          // BOUTON ENREGISTRER
          // ===================================================================
          ElevatedButton(
            onPressed: () {
              // Valider le formulaire (vérifier tous les champs)
              if (formKey.currentState!.validate()) {
                // Si tout est OK, fermer et retourner true
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(0, 211, 137, 100),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Enregistrer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // =========================================================================
    // SAUVEGARDER LES MODIFICATIONS
    // =========================================================================
    // Si l'utilisateur a cliqué sur "Enregistrer" (result == true)
    if (result == true) {
      await _updateUserInfo(
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        email: emailController.text.trim(),
      );
    }

    // =========================================================================
    // NETTOYER LES CONTRÔLEURS
    // =========================================================================
    // Toujours libérer la mémoire des contrôleurs après utilisation
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
  }

  // ===========================================================================
  // METTRE À JOUR LES INFORMATIONS DE L'UTILISATEUR
  // ===========================================================================
  // Cette fonction enregistre les nouvelles informations dans la base de données
  // ===========================================================================
  Future<void> _updateUserInfo({
    required String nom,
    required String prenom,
    required String email,
  }) async {
    if (_currentUser == null) return;

    try {
      // =======================================================================
      // CRÉER UN NOUVEL UTILISATEUR AVEC LES INFOS MODIFIÉES
      // =======================================================================
      // On utilise copyWith pour créer une copie avec les nouvelles valeurs
      final updatedUser = _currentUser!.copyWith(
        nom: nom,
        prenom: prenom,
        email: email,
      );

      // =======================================================================
      // SAUVEGARDER DANS LA BASE DE DONNÉES
      // =======================================================================
      final db = await _databaseHelper.database;
      await db.update(
        'users', // Nom de la table
        updatedUser.toMap(), // Données à sauvegarder
        where: 'id = ?', // Condition : où id = ?
        whereArgs: [updatedUser.id], // Remplacer ? par l'ID
      );

      // =======================================================================
      // METTRE À JOUR LA SESSION
      // =======================================================================
      // Sauvegarder les nouvelles infos dans la session (pour rester connecté)
      await _authService.saveUserSession(updatedUser);

      // =======================================================================
      // RECHARGER LES DONNÉES À L'ÉCRAN
      // =======================================================================
      await _loadUserData();

      // =======================================================================
      // AFFICHER UN MESSAGE DE SUCCÈS
      // =======================================================================
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Informations mises à jour avec succès'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // =======================================================================
      // AFFICHER UN MESSAGE D'ERREUR
      // =======================================================================
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Erreur lors de la mise à jour'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Déconnexion avec confirmation
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Déconnexion'),
        content: Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // =========================================================================
      // APPBAR AVEC BOUTON D'ÉDITION
      // =========================================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Paramètre',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        // =====================================================================
        // BOUTON ÉDITER EN HAUT À DROITE
        // =====================================================================
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Color.fromRGBO(0, 211, 137, 100),
              size: 28,
            ),
            onPressed: _showEditAllDialog, // Ouvrir le menu d'édition
            tooltip: 'Modifier mes informations',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  // =============================================================
                  // SECTION : INFORMATION PERSONNELLE
                  // =============================================================
                  Text(
                    'Information personnelle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Champ Nom (lecture seule)
                  _buildInfoField(
                    label: 'Nom',
                    value: _currentUser!.nom,
                  ),
                  SizedBox(height: 8),
                  // Champ Prénom (lecture seule)
                  _buildInfoField(
                    label: 'Prénom',
                    value: _currentUser!.prenom,
                  ),
                  SizedBox(height: 12),
                  
                  // =============================================================
                  // SECTION : ADRESSE
                  // =============================================================
                  Text(
                    'Adresse',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Champ Email (lecture seule)
                  _buildInfoField(
                    label: 'Email',
                    value: _currentUser!.email,
                  ),
                  SizedBox(height: 12),
                  
                  // =============================================================
                  // SECTION : SÉCURITÉ
                  // =============================================================
                  Text(
                    'Sécurité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Champ Mot de passe (masqué)
                  _buildInfoField(
                    label: 'Mot de passe',
                    value: '••••••••',
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  
                  // =============================================================
                  // BOUTON DÉCONNEXION
                  // =============================================================
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // =========================================================================
      // BARRE DE NAVIGATION EN BAS
      // =========================================================================
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  // ===========================================================================
  // WIDGET POUR AFFICHER UN CHAMP D'INFORMATION (LECTURE SEULE)
  // ===========================================================================
  // Ce widget affiche juste les informations, sans possibilité de modification
  // Pour modifier, il faut cliquer sur le bouton d'édition en haut à droite
  // ===========================================================================
  Widget _buildInfoField({
    required String label,
    required String value,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontStyle: isPassword ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

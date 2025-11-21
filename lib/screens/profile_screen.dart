import 'package:flutter/material.dart';
import 'package:projetfinal/model/users_model.dart';
import 'package:projetfinal/screens/login_screen.dart';
import 'package:projetfinal/services/auth_service.dart';
import 'package:projetfinal/services/database_helper.dart';
import 'package:projetfinal/widgets/bottom_navigation.dart';

// ==============================================================================
// PAGE DE PROFIL UTILISATEUR
// ==============================================================================
// Cette page affiche les informations personnelles de l'utilisateur connecté
// Elle permet de voir et modifier : nom, prénom, email
// On peut aussi se déconnecter depuis cette page
// C'est comme une carte d'identité modifiable !
// ==============================================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ==============================================================================
// ÉTAT DE LA PAGE DE PROFIL
// ==============================================================================
// Cette classe gère les données et les actions de la page
// ==============================================================================
class _ProfileScreenState extends State<ProfileScreen> {
  // ==========================================================================
  // SERVICES NÉCESSAIRES
  // ==========================================================================
  // AuthService = gère la session de connexion
  // DatabaseHelper = gère les opérations avec la base de données
  final AuthService _authService = AuthService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ==========================================================================
  // UTILISATEUR ACTUEL
  // ==========================================================================
  // Cette variable stocke les informations de l'utilisateur connecté
  // Elle est null au début, puis se remplit quand on charge les données
  User? _currentUser;

  // ==========================================================================
  // INITIALISATION DE LA PAGE
  // ==========================================================================
  // Cette fonction est appelée automatiquement quand la page est créée
  // C'est le moment parfait pour charger les données de l'utilisateur
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _loadUserData(); // Charger les infos de l'utilisateur
  }

  // ==========================================================================
  // CHARGER LES DONNÉES DE L'UTILISATEUR
  // ==========================================================================
  // Cette fonction récupère les informations complètes de l'utilisateur
  // depuis la base de données et les affiche à l'écran
  // ==========================================================================
  Future<void> _loadUserData() async {
    // ========================================================================
    // RÉCUPÉRER L'ID DE L'UTILISATEUR CONNECTÉ
    // ========================================================================
    final userId = _authService.getCurrentUserId();
    
    if (userId != null) {
      // ======================================================================
      // CHARGER LES DONNÉES DEPUIS LA BASE
      // ======================================================================
      final user = await _databaseHelper.getUserById(userId);
      
      if (user != null) {
        // ====================================================================
        // METTRE À JOUR L'INTERFACE
        // ====================================================================
        // setState() dit à Flutter de redessiner la page avec les nouvelles données
        setState(() {
          _currentUser = user;
        });
      }
    }
  }

  // ==========================================================================
  // AFFICHER LE MENU DE MODIFICATION COMPLET
  // ==========================================================================
  // Cette fonction affiche une grande boîte de dialogue où on peut modifier
  // TOUTES les informations de l'utilisateur en même temps
  // C'est comme ouvrir un formulaire d'édition complet !
  // ==========================================================================
  Future<void> _showEditAllDialog() async {
    // Si pas d'utilisateur chargé, on ne fait rien
    if (_currentUser == null) return;

    // ========================================================================
    // CONTRÔLEURS POUR LES CHAMPS DE TEXTE
    // ========================================================================
    // Un contrôleur = un gestionnaire qui permet de lire et modifier
    // le contenu d'un champ de texte
    // On les pré-remplit avec les valeurs actuelles
    final nomController = TextEditingController(text: _currentUser!.nom);
    final prenomController = TextEditingController(text: _currentUser!.prenom);
    final emailController = TextEditingController(text: _currentUser!.email);
    
    // Clé pour valider le formulaire (vérifier que tout est correct)
    final formKey = GlobalKey<FormState>();

    // ========================================================================
    // AFFICHER LA BOÎTE DE DIALOGUE
    // ========================================================================
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
        
        // ====================================================================
        // TITRE DE LA BOÎTE
        // ====================================================================
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.black),
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
        
        // ====================================================================
        // CONTENU DU FORMULAIRE
        // ====================================================================
        content: SingleChildScrollView(
          // SingleChildScrollView = permet de faire défiler si le contenu est trop long
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prendre le minimum d'espace
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================================================
                // SECTION : INFORMATION PERSONNELLE
                // ==============================================================
                Text(
                  'Information personnelle',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                
                // ==============================================================
                // CHAMP NOM
                // ==============================================================
                TextFormField(
                  controller: nomController, // Lié au contrôleur du nom
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Style quand le champ est sélectionné
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 211, 137, 100),
                        width: 2,
                      ),
                    ),
                  ),
                  // ============================================================
                  // VALIDATION DU NOM
                  // ============================================================
                  // Cette fonction vérifie que le nom est correct
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom ne peut pas être vide';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit avoir au moins 2 caractères';
                    }
                    return null; // null = pas d'erreur, tout est OK
                  },
                ),
                SizedBox(height: 16),
                
                // ==============================================================
                // CHAMP PRÉNOM
                // ==============================================================
                TextFormField(
                  controller: prenomController, // Lié au contrôleur du prénom
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
                  // ============================================================
                  // VALIDATION DU PRÉNOM
                  // ============================================================
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
                
                // ==============================================================
                // SECTION : ADRESSE EMAIL
                // ==============================================================
                Text(
                  'Adresse',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                
                // ==============================================================
                // CHAMP EMAIL
                // ==============================================================
                TextFormField(
                  controller: emailController, // Lié au contrôleur de l'email
                  keyboardType: TextInputType.emailAddress, // Clavier avec @
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
                  // ============================================================
                  // VALIDATION DE L'EMAIL
                  // ============================================================
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'email ne peut pas être vide';
                    }
                    // Vérifier que l'email contient @ et .
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
        
        // ====================================================================
        // BOUTONS D'ACTION
        // ====================================================================
        actions: [
          // ==================================================================
          // BOUTON ANNULER
          // ==================================================================
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
          
          // ==================================================================
          // BOUTON ENREGISTRER
          // ==================================================================
          ElevatedButton(
            onPressed: () {
              // ================================================================
              // VALIDER LE FORMULAIRE
              // ================================================================
              // validate() vérifie tous les champs avec leurs validator()
              if (formKey.currentState!.validate()) {
                // Si tout est OK, fermer et retourner true
                Navigator.pop(context, true);
              }
              // Si un champ est invalide, on reste sur la boîte
              // et l'erreur s'affiche automatiquement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(
                          118,
                          189,
                          255,
                          100,
                        ),
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

    // ========================================================================
    // SAUVEGARDER LES MODIFICATIONS
    // ========================================================================
    // Si l'utilisateur a cliqué sur "Enregistrer" (result == true)
    if (result == true) {
      await _updateUserInfo(
        nom: nomController.text.trim(), // trim() enlève les espaces
        prenom: prenomController.text.trim(),
        email: emailController.text.trim(),
      );
    }

    // ========================================================================
    // NETTOYER LES CONTRÔLEURS
    // ========================================================================
    // Toujours libérer la mémoire des contrôleurs après utilisation
    // C'est comme ranger ses outils après avoir travaillé !
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
  }

  // ==========================================================================
  // METTRE À JOUR LES INFORMATIONS DE L'UTILISATEUR
  // ==========================================================================
  // Cette fonction enregistre les nouvelles informations dans la base de données
  // et met à jour la session pour que les changements soient visibles partout
  // ==========================================================================
  Future<void> _updateUserInfo({
    required String nom,
    required String prenom,
    required String email,
  }) async {
    if (_currentUser == null) return;

    try {
      // ======================================================================
      // CRÉER UN NOUVEL UTILISATEUR AVEC LES INFOS MODIFIÉES
      // ======================================================================
      // copyWith() crée une copie de l'utilisateur avec les nouvelles valeurs
      // Les autres propriétés (comme l'ID) restent inchangées
      final updatedUser = _currentUser!.copyWith(
        nom: nom,
        prenom: prenom,
        email: email,
      );

      // ======================================================================
      // SAUVEGARDER DANS LA BASE DE DONNÉES
      // ======================================================================
      final db = await _databaseHelper.database;
      await db.update(
        'users', // Nom de la table
        updatedUser.toMap(), // Données à sauvegarder (format Map)
        where: 'id = ?', // Condition : où id = ?
        whereArgs: [updatedUser.id], // Remplacer ? par l'ID de l'utilisateur
      );

      // ======================================================================
      // METTRE À JOUR LA SESSION
      // ======================================================================
      // Sauvegarder les nouvelles infos dans la session
      // Pour que l'utilisateur reste connecté avec ses nouvelles données
      await _authService.saveUserSession(updatedUser);

      // ======================================================================
      // RECHARGER LES DONNÉES À L'ÉCRAN
      // ======================================================================
      // On recharge pour afficher les nouvelles valeurs
      await _loadUserData();

      // ======================================================================
      // AFFICHER UN MESSAGE DE SUCCÈS
      // ======================================================================
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
            backgroundColor: Colors.green, // Vert = succès
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ======================================================================
      // AFFICHER UN MESSAGE D'ERREUR
      // ======================================================================
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
            backgroundColor: Colors.red, // Rouge = erreur
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ==========================================================================
  // DÉCONNEXION AVEC CONFIRMATION
  // ==========================================================================
  // Cette fonction déconnecte l'utilisateur après lui avoir demandé confirmation
  // C'est une sécurité pour éviter les déconnexions accidentelles
  // ==========================================================================
  Future<void> _logout() async {
    // ========================================================================
    // AFFICHER LA BOÎTE DE CONFIRMATION
    // ========================================================================
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Déconnexion'),
        content: Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: Colors.grey[600]),),
          ),
          // Bouton Déconnexion
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // ========================================================================
    // SI L'UTILISATEUR A CONFIRMÉ
    // ========================================================================
    if (confirm == true) {
      // Déconnexion : effacer toutes les données de session
      await _authService.logout();
      
      if (mounted) {
        // Naviguer vers la page de connexion
        // pushAndRemoveUntil + (route) => false = supprimer toutes les pages avant
        // Cela empêche de revenir en arrière après la déconnexion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
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
      
      // ======================================================================
      // APPBAR AVEC BOUTON D'ÉDITION
      // ======================================================================
      appBar: AppBar(
        elevation: 0, // Pas d'ombre sous la barre
        backgroundColor: Colors.white,
        title: Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Pas de bouton retour
        
        // ====================================================================
        // BOUTON ÉDITER EN HAUT À DROITE
        // ====================================================================
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.black,
              size: 28,
            ),
            onPressed: _showEditAllDialog, // Ouvrir le menu d'édition
            tooltip: 'Modifier mes informations',
          ),
          SizedBox(width: 8),
        ],
      ),
      
      // ======================================================================
      // CORPS DE LA PAGE
      // ======================================================================
      body: _currentUser == null
          // Si pas d'utilisateur chargé, afficher un spinner
          ? Center(child: CircularProgressIndicator())
          // Sinon, afficher les informations
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  
                  // ==============================================================
                  // SECTION : INFORMATION PERSONNELLE
                  // ==============================================================
                  Text(
                    'Information personnelle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  
                  // ==============================================================
                  // SECTION : ADRESSE
                  // ==============================================================
                  Text(
                    'Adresse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Champ Email (lecture seule)
                  _buildInfoField(
                    label: 'Email',
                    value: _currentUser!.email,
                  ),
                  SizedBox(height: 12),
                  
                  // ==============================================================
                  // SECTION : SÉCURITÉ
                  // ==============================================================
                  Text(
                    'Sécurité',
                    style: TextStyle(
                      fontSize: 18,
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
                  
                  // ==============================================================
                  // BOUTON DÉCONNEXION
                  // ==============================================================
                  Center(
                    child: SizedBox(
                      width: double.infinity, // Prendre toute la largeur
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFFB71C1C), // Rouge foncé
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      // ======================================================================
      // BARRE DE NAVIGATION EN BAS
      // ======================================================================
      // currentIndex: 1 car on est sur l'onglet Profil (deuxième onglet)
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  // ==========================================================================
  // WIDGET POUR AFFICHER UN CHAMP D'INFORMATION (LECTURE SEULE)
  // ==========================================================================
  // Ce widget affiche juste les informations, sans possibilité de modification
  // Pour modifier, il faut cliquer sur le bouton d'édition en haut à droite
  // C'est comme une vitrine : on peut regarder mais pas toucher !
  // ==========================================================================
  Widget _buildInfoField({
    required String label, // Le label n'est pas utilisé dans l'affichage actuel
    required String value, // La valeur à afficher
    bool isPassword = false, // Est-ce un mot de passe ?
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2), // Bordure noire
        borderRadius: BorderRadius.circular(12), // Coins arrondis
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          // Si c'est un mot de passe, afficher en italique
          fontStyle: isPassword ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}
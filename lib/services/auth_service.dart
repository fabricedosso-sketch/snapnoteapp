import 'package:projetfinal/model/users_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==============================================================================
// SERVICE DE GESTION DE L'AUTHENTIFICATION
// ==============================================================================
// AuthService gère la session de l'utilisateur connecté
// Il permet de savoir QUI est connecté et de sauvegarder cette information
// même quand on ferme et rouvre l'application
// C'est comme un gardien qui se souvient de qui est entré dans le bâtiment !
// ==============================================================================
class AuthService {
  // ==========================================================================
  // SINGLETON : UNE SEULE INSTANCE POUR TOUTE L'APPLICATION
  // ==========================================================================
  // On utilise le pattern Singleton pour avoir un seul gestionnaire de session
  // Pourquoi ? Pour éviter d'avoir plusieurs versions des infos utilisateur
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ==========================================================================
  // UTILISATEUR ACTUELLEMENT CONNECTÉ
  // ==========================================================================
  // Cette variable stocke les informations de l'utilisateur connecté
  // Si elle est null, cela signifie que personne n'est connecté
  User? _currentUser;
  
  // ==========================================================================
  // CLÉS POUR LE STOCKAGE LOCAL
  // ==========================================================================
  // Ces clés sont utilisées pour sauvegarder/récupérer les données
  // dans SharedPreferences (le stockage permanent du téléphone)
  // C'est comme les étiquettes sur des boîtes de rangement !
  static const String _keyUserId = 'userId';
  static const String _keyNom = 'nom';
  static const String _keyPrenom = 'prenom';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  // ==========================================================================
  // GETTER POUR OBTENIR L'UTILISATEUR CONNECTÉ
  // ==========================================================================
  // Cette fonction permet d'accéder à l'utilisateur connecté depuis n'importe où
  User? get currentUser => _currentUser;
  
  // ==========================================================================
  // VÉRIFIER SI QUELQU'UN EST CONNECTÉ
  // ==========================================================================
  // Cette fonction retourne true si un utilisateur est connecté, false sinon
  // C'est une vérification rapide : "Y a-t-il quelqu'un ?"
  bool get isLoggedIn => _currentUser != null;

  // ==========================================================================
  // SAUVEGARDER LA SESSION D'UN UTILISATEUR
  // ==========================================================================
  // Cette fonction est appelée après une connexion ou une inscription réussie
  // Elle sauvegarde les informations de l'utilisateur pour les retrouver
  // même après avoir fermé et rouvert l'application
  // ==========================================================================
  Future<void> saveUserSession(User user) async {
    // ========================================================================
    // METTRE À JOUR L'UTILISATEUR EN MÉMOIRE
    // ========================================================================
    // On stocke d'abord l'utilisateur dans la variable _currentUser
    // Cela permet d'y accéder rapidement pendant que l'app est ouverte
    _currentUser = user;
    
    // ========================================================================
    // OBTENIR L'ACCÈS AU STOCKAGE LOCAL
    // ========================================================================
    // SharedPreferences = un système de stockage permanent sur le téléphone
    // C'est comme un petit carnet où on note des informations importantes
    final prefs = await SharedPreferences.getInstance();
    
    // ========================================================================
    // SAUVEGARDER CHAQUE INFORMATION
    // ========================================================================
    // On sauvegarde chaque propriété de l'utilisateur séparément
    // avec sa clé correspondante
    await prefs.setInt(_keyUserId, user.id!); // L'ID (nombre entier)
    await prefs.setString(_keyNom, user.nom); // Le nom (texte)
    await prefs.setString(_keyPrenom, user.prenom); // Le prénom (texte)
    await prefs.setString(_keyEmail, user.email); // L'email (texte)
    await prefs.setBool(_keyIsLoggedIn, true); // Statut connecté (vrai/faux)
    
    // IMPORTANT : On ne sauvegarde JAMAIS le mot de passe localement
    // pour des raisons de sécurité !
  }

  // ==========================================================================
  // CHARGER LA SESSION AU DÉMARRAGE
  // ==========================================================================
  // Cette fonction est appelée quand l'application démarre
  // Elle vérifie si un utilisateur était connecté la dernière fois
  // Si oui, elle recharge ses informations pour le reconnecter automatiquement
  // C'est comme retrouver son badge pour rentrer dans le bâtiment !
  // ==========================================================================
  Future<bool> loadUserSession() async {
    // Obtenir l'accès au stockage local
    final prefs = await SharedPreferences.getInstance();
    
    // ========================================================================
    // VÉRIFIER SI UN UTILISATEUR ÉTAIT CONNECTÉ
    // ========================================================================
    // On vérifie d'abord le flag "isLoggedIn"
    // ?? false = si la valeur n'existe pas, on considère que c'est false
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    // Si personne n'était connecté, on arrête ici
    if (!isLoggedIn) return false;

    // ========================================================================
    // RÉCUPÉRER LES INFORMATIONS SAUVEGARDÉES
    // ========================================================================
    // On récupère chaque information avec sa clé
    final userId = prefs.getInt(_keyUserId);
    final nom = prefs.getString(_keyNom);
    final prenom = prefs.getString(_keyPrenom);
    final email = prefs.getString(_keyEmail);

    // ========================================================================
    // VALIDER QUE TOUTES LES INFORMATIONS SONT PRÉSENTES
    // ========================================================================
    // Si une seule information manque, la session est considérée comme invalide
    // C'est comme un badge incomplet : on ne peut pas entrer !
    if (userId == null || nom == null || prenom == null || email == null) {
      return false;
    }

    // ========================================================================
    // RECRÉER L'OBJET USER
    // ========================================================================
    // On reconstruit l'utilisateur avec les informations récupérées
    _currentUser = User(
      id: userId,
      nom: nom,
      prenom: prenom,
      email: email,
      motDePasse: '', // On laisse vide : on ne stocke jamais le mot de passe
    );

    return true; // Session chargée avec succès !
  }

  // ==========================================================================
  // DÉCONNEXION
  // ==========================================================================
  // Cette fonction déconnecte l'utilisateur actuel
  // Elle efface toutes ses informations de la mémoire et du stockage local
  // C'est comme rendre son badge en sortant du bâtiment !
  // ==========================================================================
  Future<void> logout() async {
    // ========================================================================
    // EFFACER L'UTILISATEUR DE LA MÉMOIRE
    // ========================================================================
    // On met _currentUser à null pour indiquer que personne n'est connecté
    _currentUser = null;
    
    // ========================================================================
    // EFFACER TOUTES LES DONNÉES DU STOCKAGE LOCAL
    // ========================================================================
    // clear() supprime TOUTES les données de SharedPreferences
    // Cela garantit qu'aucune trace de la session ne reste
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==========================================================================
  // OBTENIR L'ID DE L'UTILISATEUR CONNECTÉ
  // ==========================================================================
  // Cette fonction retourne l'ID de l'utilisateur connecté
  // Retourne null si personne n'est connecté
  // Utile pour faire des requêtes à la base de données liées à cet utilisateur
  // ==========================================================================
  int? getCurrentUserId() {
    return _currentUser?.id;
    // Le ? après _currentUser signifie : 
    // "Si _currentUser est null, retourne null directement sans essayer d'accéder à .id"
  }

  // ==========================================================================
  // OBTENIR LE NOM COMPLET DE L'UTILISATEUR
  // ==========================================================================
  // Cette fonction retourne le prénom de l'utilisateur connecté
  // Si personne n'est connecté, elle retourne "Utilisateur" par défaut
  // Utile pour afficher "Bonjour, Jean" dans l'interface
  // ==========================================================================
  String getCurrentUserFullName() {
    // Si personne n'est connecté, retourner un nom par défaut
    if (_currentUser == null) return 'Utilisateur';
    
    // Sinon, retourner le prénom de l'utilisateur
    return '${_currentUser!.prenom}';
    // Le ! après _currentUser signifie :
    // "Je suis sûr que _currentUser n'est pas null ici (on vient de le vérifier)"
  }
}
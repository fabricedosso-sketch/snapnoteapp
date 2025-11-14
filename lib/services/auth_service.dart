import 'package:projetfinal/model/users_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service qui gère la session de l'utilisateur connecté
/// Permet de savoir qui est connecté et de sauvegarder cette information
class AuthService {
  // Instance unique (Singleton)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // L'utilisateur actuellement connecté (null si personne n'est connecté)
  User? _currentUser;
  
  // Clés utilisées pour stocker les données dans SharedPreferences
  static const String _keyUserId = 'userId';
  static const String _keyNom = 'nom';
  static const String _keyPrenom = 'prenom';
  static const String _keyEmail = 'email';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  /// Getter pour obtenir l'utilisateur connecté
  User? get currentUser => _currentUser;
  
  /// Vérifie si un utilisateur est connecté
  bool get isLoggedIn => _currentUser != null;

  /// Sauvegarder la session d'un utilisateur
  /// Cette fonction est appelée après une connexion ou une inscription réussie
  Future<void> saveUserSession(User user) async {
    // Mettre à jour l'utilisateur en mémoire
    _currentUser = user;
    
    // Obtenir l'instance de SharedPreferences (stockage local)
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder les informations de l'utilisateur
    await prefs.setInt(_keyUserId, user.id!);
    await prefs.setString(_keyNom, user.nom);
    await prefs.setString(_keyPrenom, user.prenom);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Charger la session au démarrage de l'application
  /// Permet de garder l'utilisateur connecté même après avoir fermé l'app
  Future<bool> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Vérifier si un utilisateur est connecté
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    // Si personne n'est connecté, retourner false
    if (!isLoggedIn) return false;

    // Récupérer les informations sauvegardées
    final userId = prefs.getInt(_keyUserId);
    final nom = prefs.getString(_keyNom);
    final prenom = prefs.getString(_keyPrenom);
    final email = prefs.getString(_keyEmail);

    // Si une information manque, la session est invalide
    if (userId == null || nom == null || prenom == null || email == null) {
      return false;
    }

    // Recréer l'objet User avec les informations sauvegardées
    _currentUser = User(
      id: userId,
      nom: nom,
      prenom: prenom,
      email: email,
      motDePasse: '', // On ne stocke jamais le mot de passe localement
    );

    return true; // Session chargée avec succès
  }

  /// Déconnexion
  /// Efface toutes les données de session
  Future<void> logout() async {
    // Effacer l'utilisateur en mémoire
    _currentUser = null;
    
    // Effacer toutes les données de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Obtenir l'ID de l'utilisateur connecté
  /// Retourne null si personne n'est connecté
  int? getCurrentUserId() {
    return _currentUser?.id;
  }

  /// Obtenir le nom complet de l'utilisateur connecté
  String getCurrentUserFullName() {
    if (_currentUser == null) return 'Utilisateur';
    return '${_currentUser!.prenom}';
  }
}
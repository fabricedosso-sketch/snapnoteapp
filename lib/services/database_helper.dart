import 'package:projetfinal/model/users_model.dart';
import 'package:path/path.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Classe qui gère toutes les opérations de base de données
/// Utilise le pattern Singleton pour avoir une seule instance dans toute l'app
class DatabaseHelper {
  // Instance unique de DatabaseHelper (Singleton)
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Variable qui contiendra notre base de données
  static Database? _database;

  // Factory constructor qui retourne toujours la même instance
  factory DatabaseHelper() => _instance;

  // Constructeur privé pour empêcher la création d'autres instances
  DatabaseHelper._internal();

  /// Getter qui retourne la base de données
  /// Si elle n'existe pas, on l'initialise
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données
  /// Crée le fichier de la base et définit sa structure
  Future<Database> _initDatabase() async {
    // Obtenir le chemin où stocker la base de données
    String path = join(await getDatabasesPath(), 'snapnote.db');

    // Ouvrir/créer la base de données
    return await openDatabase(
      path,
      version: 1, // Version de la base (à incrémenter lors de modifications)
      onCreate: _onCreate, // Fonction appelée lors de la création
    );
  }

  /// Crée les tables de la base de données
  /// Cette fonction est appelée automatiquement lors de la première utilisation
  Future<void> _onCreate(Database db, int version) async {
    // Créer la table des utilisateurs
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Créer la table des notes avec une relation vers users
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT,
        content TEXT,
        color TEXT,
        dateTime TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // ========== GESTION DES UTILISATEURS ==========

  /// Fonction pour hasher (crypter) les mots de passe
  /// Utilise l'algorithme SHA256 pour sécuriser les mots de passe
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convertir en bytes
    var digest = sha256.convert(bytes); // Appliquer SHA256
    return digest.toString(); // Retourner le hash en string
  }

  /// Inscription d'un nouvel utilisateur
  /// Vérifie que l'email n'existe pas déjà
  /// Retourne un Map avec le résultat de l'opération
  Future<Map<String, dynamic>> registerUser(User user) async {
    final db = await database;

    try {
      // Vérifier si l'email existe déjà dans la base
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user.email],
      );

      // Si l'email existe déjà, on refuse l'inscription
      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Cet email est déjà utilisé'};
      }

      // Créer un nouvel utilisateur avec le mot de passe hashé
      final newUser = User(
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        motDePasse: _hashPassword(user.motDePasse),
      );

      // Insérer l'utilisateur dans la base
      int userId = await db.insert('users', newUser.toMap());

      // Récupérer l'utilisateur créé avec son ID
      final createdUser = User(
        id: userId,
        nom: newUser.nom,
        prenom: newUser.prenom,
        email: newUser.email,
        motDePasse: newUser.motDePasse,
      );

      // Retourner le succès avec les infos de l'utilisateur
      return {
        'success': true,
        'message': 'Compte créé avec succès',
        'user': createdUser,
      };
    } catch (e) {
      // En cas d'erreur, retourner un message d'erreur
      return {
        'success': false,
        'message': 'Erreur lors de la création du compte: $e',
      };
    }
  }

  /// Connexion d'un utilisateur
  /// Vérifie l'email et le mot de passe
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    try {
      // Chercher un utilisateur avec cet email et ce mot de passe
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, _hashPassword(password)],
      );

      // Si aucun utilisateur trouvé, les identifiants sont incorrects
      if (users.isEmpty) {
        return {'success': false, 'message': 'Email ou mot de passe incorrect'};
      }

      // Convertir le résultat en objet User
      final user = User.fromMap(users.first);

      // Retourner le succès avec les infos de l'utilisateur
      return {'success': true, 'message': 'Connexion réussie', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Erreur lors de la connexion: $e'};
    }
  }

  /// Récupérer un utilisateur par son ID
  Future<User?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return null;
    return User.fromMap(users.first);
  }

  // ========== GESTION DES NOTES ==========

  /// Insérer une nouvelle note pour un utilisateur spécifique
  Future<int> insertNote(Note note, int userId) async {
    final db = await database;

    // Créer une copie de la note avec l'userId
    final noteMap = note.toMap();
    noteMap['userId'] = userId;

    // Insérer la note dans la base
    return await db.insert('notes', noteMap);
  }

  /// Récupérer toutes les notes d'un utilisateur
  /// Les notes sont triées par date (plus récentes en premier)
  Future<List<Note>> getNotes(int userId) async {
    final db = await database;

    // Requête pour obtenir uniquement les notes de cet utilisateur
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dateTime DESC', // Trier par date décroissante
    );

    // Convertir les résultats en liste de Notes
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Mettre à jour une note existante
  Future<int> updateNote(Note note) async {
    final db = await database;

    // Mettre à jour la note dans la base
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Supprimer une note par son ID
  Future<int> deleteNote(int id) async {
    final db = await database;

    // Supprimer la note de la base
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Compter le nombre de notes d'un utilisateur
  Future<int> getNotesCount(int userId) async {
    final db = await database;

    // Requête SQL pour compter les notes
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE userId = ?',
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== UTILITAIRES ==========

  /// Supprimer toutes les données (utile pour les tests)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('notes');
    await db.delete('users');
  }

  /// Fermer la base de données
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

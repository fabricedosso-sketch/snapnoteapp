import 'package:projetfinal/model/users_model.dart';
import 'package:path/path.dart';
import 'package:projetfinal/model/notes_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ==============================================================================
// CLASSE DE GESTION DE LA BASE DE DONNÉES
// ==============================================================================
// DatabaseHelper gère toutes les opérations avec la base de données SQLite
// Elle utilise le pattern Singleton : une seule instance dans toute l'application
// C'est comme avoir un seul bibliothécaire pour gérer toute la bibliothèque !
// ==============================================================================
class DatabaseHelper {
  // ==========================================================================
  // SINGLETON : UNE SEULE INSTANCE POUR TOUTE L'APPLICATION
  // ==========================================================================
  // Le pattern Singleton garantit qu'on a toujours la même instance
  // Pourquoi ? Pour éviter d'avoir plusieurs connexions à la base de données
  // _instance = l'unique instance de DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Variable qui contiendra notre base de données une fois ouverte
  static Database? _database;

  // ==========================================================================
  // FACTORY CONSTRUCTOR
  // ==========================================================================
  // Quand on fait DatabaseHelper(), cette fonction retourne toujours _instance
  // C'est comme demander "le" bibliothécaire : on a toujours la même personne !
  factory DatabaseHelper() => _instance;

  // ==========================================================================
  // CONSTRUCTEUR PRIVÉ
  // ==========================================================================
  // Le _ devant "internal" rend ce constructeur privé
  // Personne ne peut créer une nouvelle instance directement
  // On DOIT passer par le factory constructor ci-dessus
  DatabaseHelper._internal();

  // ==========================================================================
  // GETTER POUR ACCÉDER À LA BASE DE DONNÉES
  // ==========================================================================
  // Cette fonction retourne la base de données
  // Si elle n'existe pas encore, on la crée d'abord
  // C'est comme ouvrir la bibliothèque : si elle n'existe pas, on la construit !
  // ==========================================================================
  Future<Database> get database async {
    // Si la base existe déjà, on la retourne directement
    if (_database != null) return _database!;
    
    // Sinon, on l'initialise
    _database = await _initDatabase();
    return _database!;
  }

  // ==========================================================================
  // INITIALISATION DE LA BASE DE DONNÉES
  // ==========================================================================
  // Cette fonction crée le fichier de la base de données sur le téléphone
  // Elle définit aussi où stocker ce fichier et quelle version on utilise
  // ==========================================================================
  Future<Database> _initDatabase() async {
    // ========================================================================
    // OBTENIR LE CHEMIN DE STOCKAGE
    // ========================================================================
    // getDatabasesPath() = l'endroit où Android/iOS stockent les bases de données
    // join() = combine le chemin avec le nom du fichier : "snapnote.db"
    String path = join(await getDatabasesPath(), 'snapnote.db');

    // ========================================================================
    // OUVRIR OU CRÉER LA BASE DE DONNÉES
    // ========================================================================
    return await openDatabase(
      path, // Le chemin complet du fichier
      version: 1, // Numéro de version (à changer si on modifie la structure)
      onCreate: _onCreate, // Fonction à appeler si la base n'existe pas encore
    );
  }

  // ==========================================================================
  // CRÉATION DES TABLES
  // ==========================================================================
  // Cette fonction est appelée automatiquement la première fois
  // Elle crée la structure de notre base : les tables et leurs colonnes
  // C'est comme construire les étagères dans notre bibliothèque !
  // ==========================================================================
  Future<void> _onCreate(Database db, int version) async {
    // ========================================================================
    // TABLE DES UTILISATEURS
    // ========================================================================
    // Cette table stocke tous les comptes utilisateurs
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    // Explication des colonnes :
    // - id : numéro unique auto-généré pour chaque utilisateur
    // - nom : nom de famille (TEXT = texte, NOT NULL = obligatoire)
    // - prenom : prénom
    // - email : adresse email (UNIQUE = pas de doublon)
    // - password : mot de passe crypté

    // ========================================================================
    // TABLE DES NOTES
    // ========================================================================
    // Cette table stocke toutes les notes créées par les utilisateurs
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
    // Explication des colonnes :
    // - id : numéro unique de la note
    // - userId : à quel utilisateur appartient cette note
    // - title : titre de la note (peut être vide)
    // - content : contenu de la note
    // - color : couleur de la note (stockée comme texte)
    // - dateTime : date et heure de création
    // - FOREIGN KEY : lien vers la table users
    //   ON DELETE CASCADE = si on supprime l'utilisateur, ses notes sont supprimées aussi
  }

  // ==============================================================================
  // GESTION DES UTILISATEURS
  // ==============================================================================

  // ==========================================================================
  // CRYPTAGE DES MOTS DE PASSE
  // ==========================================================================
  // Cette fonction transforme un mot de passe en une chaîne cryptée
  // On n'enregistre JAMAIS le mot de passe en clair pour la sécurité !
  // C'est comme transformer "1234" en "a94f28b3c..." : impossible à deviner !
  // ==========================================================================
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convertir le texte en bytes (données brutes)
    var digest = sha256.convert(bytes); // Appliquer l'algorithme SHA256
    return digest.toString(); // Retourner le résultat crypté en texte
  }

  // ==========================================================================
  // INSCRIPTION D'UN NOUVEL UTILISATEUR
  // ==========================================================================
  // Cette fonction crée un nouveau compte utilisateur dans la base
  // Elle vérifie d'abord que l'email n'est pas déjà utilisé
  // Retourne un Map avec le résultat : succès ou échec avec un message
  // ==========================================================================
  Future<Map<String, dynamic>> registerUser(User user) async {
    final db = await database; // Récupérer la base de données

    try {
      // ======================================================================
      // VÉRIFIER SI L'EMAIL EXISTE DÉJÀ
      // ======================================================================
      // On cherche dans la table users si cet email existe
      final existingUser = await db.query(
        'users', // Nom de la table
        where: 'email = ?', // Condition : email égal à...
        whereArgs: [user.email], // ... cette valeur
      );

      // Si on trouve un résultat, l'email est déjà pris
      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Cet email est déjà utilisé'};
      }

      // ======================================================================
      // CRÉER L'UTILISATEUR AVEC MOT DE PASSE CRYPTÉ
      // ======================================================================
      // On crée une nouvelle instance User avec le mot de passe hashé
      final newUser = User(
        nom: user.nom,
        prenom: user.prenom,
        email: user.email,
        motDePasse: _hashPassword(user.motDePasse), // Crypter le mot de passe
      );

      // ======================================================================
      // INSÉRER DANS LA BASE DE DONNÉES
      // ======================================================================
      // insert() ajoute une ligne dans la table et retourne l'ID généré
      int userId = await db.insert('users', newUser.toMap());

      // ======================================================================
      // CRÉER L'OBJET USER COMPLET AVEC SON ID
      // ======================================================================
      final createdUser = User(
        id: userId, // L'ID généré automatiquement
        nom: newUser.nom,
        prenom: newUser.prenom,
        email: newUser.email,
        motDePasse: newUser.motDePasse,
      );

      // Retourner le succès avec les infos du nouvel utilisateur
      return {
        'success': true,
        'message': 'Compte créé avec succès',
        'user': createdUser,
      };
    } catch (e) {
      // ======================================================================
      // GESTION DES ERREURS
      // ======================================================================
      // Si quelque chose se passe mal, on capture l'erreur
      return {
        'success': false,
        'message': 'Erreur lors de la création du compte: $e',
      };
    }
  }

  // ==========================================================================
  // CONNEXION D'UN UTILISATEUR
  // ==========================================================================
  // Cette fonction vérifie si l'email et le mot de passe sont corrects
  // Si oui, elle retourne les informations de l'utilisateur
  // Si non, elle retourne un message d'erreur
  // ==========================================================================
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database; // Récupérer la base de données

    try {
      // ======================================================================
      // CHERCHER L'UTILISATEUR DANS LA BASE
      // ======================================================================
      // On cherche un utilisateur avec cet email ET ce mot de passe (crypté)
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password = ?', // Deux conditions
        whereArgs: [email, _hashPassword(password)], // Les deux valeurs
      );

      // ======================================================================
      // VÉRIFIER SI UN UTILISATEUR A ÉTÉ TROUVÉ
      // ======================================================================
      // Si la liste est vide, aucun utilisateur ne correspond
      if (users.isEmpty) {
        return {'success': false, 'message': 'Email ou mot de passe incorrect'};
      }

      // ======================================================================
      // CONVERTIR LE RÉSULTAT EN OBJET USER
      // ======================================================================
      // users.first = le premier (et unique) résultat de la requête
      // fromMap() = transforme les données de la base en objet User
      final user = User.fromMap(users.first);

      // Retourner le succès avec les informations de l'utilisateur
      return {'success': true, 'message': 'Connexion réussie', 'user': user};
    } catch (e) {
      // Gestion des erreurs
      return {'success': false, 'message': 'Erreur lors de la connexion: $e'};
    }
  }

  // ==========================================================================
  // RÉCUPÉRER UN UTILISATEUR PAR SON ID
  // ==========================================================================
  // Cette fonction cherche un utilisateur en utilisant son numéro d'ID
  // Retourne l'utilisateur trouvé ou null si aucun résultat
  // ==========================================================================
  Future<User?> getUserById(int userId) async {
    final db = await database;
    
    // Chercher l'utilisateur avec cet ID
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Si aucun résultat, retourner null
    if (users.isEmpty) return null;
    
    // Sinon, convertir et retourner l'utilisateur
    return User.fromMap(users.first);
  }

  // ==============================================================================
  // GESTION DES NOTES
  // ==============================================================================

  // ==========================================================================
  // INSÉRER UNE NOUVELLE NOTE
  // ==========================================================================
  // Cette fonction ajoute une nouvelle note dans la base de données
  // Elle associe automatiquement la note à l'utilisateur qui l'a créée
  // ==========================================================================
  Future<int> insertNote(Note note, int userId) async {
    final db = await database;

    // ========================================================================
    // AJOUTER L'ID DE L'UTILISATEUR À LA NOTE
    // ========================================================================
    // On convertit d'abord la note en Map (dictionnaire clé-valeur)
    final noteMap = note.toMap();
    // Puis on ajoute le userId pour lier la note à son propriétaire
    noteMap['userId'] = userId;

    // Insérer la note dans la table et retourner son ID
    return await db.insert('notes', noteMap);
  }

  // ==========================================================================
  // RÉCUPÉRER TOUTES LES NOTES D'UN UTILISATEUR
  // ==========================================================================
  // Cette fonction récupère uniquement les notes de l'utilisateur connecté
  // Les notes sont triées par date : les plus récentes apparaissent en premier
  // ==========================================================================
  Future<List<Note>> getNotes(int userId) async {
    final db = await database;

    // ========================================================================
    // REQUÊTE POUR OBTENIR LES NOTES
    // ========================================================================
    final List<Map<String, dynamic>> maps = await db.query(
      'notes', // Table à consulter
      where: 'userId = ?', // Filtrer par userId
      whereArgs: [userId], // L'ID de l'utilisateur
      orderBy: 'dateTime DESC', // Trier par date décroissante (DESC = descendant)
      // DESC = du plus récent au plus ancien
    );

    // ========================================================================
    // CONVERTIR LES RÉSULTATS EN LISTE DE NOTES
    // ========================================================================
    // List.generate() = créer une liste en transformant chaque élément
    // Pour chaque Map dans maps, on crée un objet Note
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  // ==========================================================================
  // METTRE À JOUR UNE NOTE EXISTANTE
  // ==========================================================================
  // Cette fonction modifie une note déjà présente dans la base
  // Par exemple : changer le titre, le contenu ou la couleur
  // ==========================================================================
  Future<int> updateNote(Note note) async {
    final db = await database;

    // Mettre à jour la ligne dans la table notes
    return await db.update(
      'notes', // Table à modifier
      note.toMap(), // Nouvelles valeurs
      where: 'id = ?', // Condition : l'ID doit correspondre
      whereArgs: [note.id], // L'ID de la note à modifier
    );
    // Retourne le nombre de lignes modifiées (normalement 1)
  }

  // ==========================================================================
  // SUPPRIMER UNE NOTE
  // ==========================================================================
  // Cette fonction supprime définitivement une note de la base
  // ==========================================================================
  Future<int> deleteNote(int id) async {
    final db = await database;

    // Supprimer la note avec cet ID
    return await db.delete(
      'notes', // Table concernée
      where: 'id = ?', // Condition
      whereArgs: [id], // L'ID de la note à supprimer
    );
    // Retourne le nombre de lignes supprimées (normalement 1)
  }

  // ==========================================================================
  // COMPTER LE NOMBRE DE NOTES D'UN UTILISATEUR
  // ==========================================================================
  // Cette fonction compte combien de notes possède un utilisateur
  // Utile pour afficher des statistiques sur le profil par exemple
  // ==========================================================================
  Future<int> getNotesCount(int userId) async {
    final db = await database;

    // ========================================================================
    // REQUÊTE SQL POUR COMPTER
    // ========================================================================
    // rawQuery = exécuter une requête SQL personnalisée
    // COUNT(*) = compter le nombre de lignes
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notes WHERE userId = ?',
      [userId],
    );

    // Extraire le premier résultat (le nombre) ou retourner 0 si vide
    return Sqflite.firstIntValue(result) ?? 0;
    // ?? 0 = si le résultat est null, retourner 0 par défaut
  }

  // ==============================================================================
  // FONCTIONS UTILITAIRES
  // ==============================================================================

  // ==========================================================================
  // SUPPRIMER TOUTES LES DONNÉES
  // ==========================================================================
  // Cette fonction vide complètement la base de données
  // Utile pour les tests ou pour réinitialiser l'application
  // ATTENTION : Cette action est irréversible !
  // ==========================================================================
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('notes'); // Supprimer toutes les notes
    await db.delete('users'); // Supprimer tous les utilisateurs
  }

  // ==========================================================================
  // FERMER LA BASE DE DONNÉES
  // ==========================================================================
  // Cette fonction ferme proprement la connexion à la base
  // C'est comme fermer la bibliothèque en fin de journée !
  // ==========================================================================
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close(); // Fermer la connexion
    _database = null; // Réinitialiser la variable
  }
}
/// Classe qui représente un Utilisateur dans l'application
/// Chaque utilisateur peut avoir plusieurs notes
class User {
  final int? id;            // ID unique de l'utilisateur (null lors de la création)
  final String nom;         // Nom de famille de l'utilisateur
  final String prenom;      // Prénom de l'utilisateur
  final String email;       // Email (unique) pour la connexion
  final String motDePasse;  // Mot de passe (hashé dans la base de données)

  /// Constructeur principal avec tous les paramètres
  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
  });

  /// Constructeur alternatif sans ID
  /// Utilisé lors de la création d'un nouvel utilisateur
  /// (l'ID sera généré automatiquement par la base de données)
  User.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
  }) : id = null;

  /// Convertir un objet User en Map (dictionnaire)
  /// Utilisé pour enregistrer l'utilisateur dans la base de données SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': motDePasse,  // Note: clé 'password' dans la DB
    };
  }

  /// Créer un objet User à partir d'un Map
  /// Utilisé pour lire les utilisateurs depuis la base de données
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      motDePasse: map['password'],  // Note: clé 'password' dans la DB
    );
  }

  /// Créer une copie de l'utilisateur avec des modifications
  /// Utile pour modifier certains champs sans changer les autres
  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
    );
  }

  /// Représentation en String pour le débogage
  /// Affiche les infos de l'utilisateur (sans le mot de passe pour la sécurité)
  @override
  String toString() {
    return 'User(id: $id, nom: $nom, prenom: $prenom, email: $email)';
  }

  /// Vérifier l'égalité entre deux utilisateurs
  /// Deux utilisateurs sont égaux s'ils ont le même ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  /// Hash code basé sur l'ID
  /// Nécessaire pour utiliser User dans des Set ou comme clé de Map
  @override
  int get hashCode => id.hashCode;

  /// Obtenir le nom complet de l'utilisateur
  /// Utile pour l'affichage dans l'interface
  String get nomComplet => '$prenom $nom';

  /// Obtenir les initiales de l'utilisateur
  /// Exemple: "Fabrice Kouassi" → "FK"
  String get initiales {
    final firstLetter = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final lastLetter = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$firstLetter$lastLetter';
  }
}
// ==============================================================================
// MODÈLE DE DONNÉES : UTILISATEUR
// ==============================================================================
// Cette classe représente un Utilisateur dans l'application
// C'est comme un plan ou un moule qui définit ce qu'est un utilisateur
// Chaque utilisateur peut créer et gérer plusieurs notes
// ==============================================================================
class User {
  // ==========================================================================
  // PROPRIÉTÉS D'UN UTILISATEUR
  // ==========================================================================
  // Ce sont les informations que chaque utilisateur contient
  
  // L'ID unique de l'utilisateur (comme un numéro de carte d'identité)
  // Il est null lors de la création car il sera généré automatiquement par la base
  final int? id;
  
  // Le nom de famille de l'utilisateur (ex: "Kouassi")
  final String nom;
  
  // Le prénom de l'utilisateur (ex: "Fabrice")
  final String prenom;
  
  // L'adresse email (unique pour chaque utilisateur)
  // C'est l'identifiant de connexion
  final String email;
  
  // Le mot de passe (sera crypté/hashé avant d'être stocké dans la base)
  // On ne stocke JAMAIS le mot de passe en clair pour la sécurité !
  final String motDePasse;

  // ==========================================================================
  // CONSTRUCTEUR PRINCIPAL
  // ==========================================================================
  // Ce constructeur permet de créer un utilisateur avec tous les champs
  // Certains sont obligatoires (required), l'id est optionnel
  // ==========================================================================
  User({
    this.id,                    // Optionnel : null lors de la création
    required this.nom,          // Obligatoire
    required this.prenom,       // Obligatoire
    required this.email,        // Obligatoire
    required this.motDePasse,   // Obligatoire
  });

  // ==========================================================================
  // CONSTRUCTEUR ALTERNATIF SANS ID
  // ==========================================================================
  // Ce constructeur est utilisé lors de la création d'un nouvel utilisateur
  // Il ne demande pas l'ID car celui-ci sera généré automatiquement
  // C'est plus pratique : on n'a pas besoin de passer null pour l'ID
  // ==========================================================================
  User.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
  }) : id = null;  // : id = null signifie qu'on initialise id à null

  // ==========================================================================
  // CONVERTIR UN UTILISATEUR EN MAP (DICTIONNAIRE)
  // ==========================================================================
  // Cette fonction transforme l'objet User en Map (dictionnaire clé-valeur)
  // Pourquoi ? Parce que SQLite stocke les données sous forme de Map
  // C'est comme traduire notre utilisateur dans le langage de la base !
  // ==========================================================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,               // Clé 'id' → valeur de l'id
      'nom': nom,             // Clé 'nom' → valeur du nom
      'prenom': prenom,       // Clé 'prenom' → valeur du prénom
      'email': email,         // Clé 'email' → valeur de l'email
      'password': motDePasse, // Clé 'password' dans la DB (pas 'motDePasse')
      // ATTENTION : La clé est 'password' pour correspondre à la structure de la table
    };
  }

  // ==========================================================================
  // CRÉER UN UTILISATEUR À PARTIR D'UN MAP
  // ==========================================================================
  // Cette fonction fait l'inverse de toMap()
  // Elle prend un Map (récupéré de la base de données) et crée un objet User
  // C'est comme traduire les données de la base en utilisateur utilisable !
  // factory = un type spécial de constructeur
  // ==========================================================================
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],              // Récupérer l'id depuis le Map
      nom: map['nom'],            // Récupérer le nom depuis le Map
      prenom: map['prenom'],      // Récupérer le prénom depuis le Map
      email: map['email'],        // Récupérer l'email depuis le Map
      motDePasse: map['password'], // La clé est 'password' dans la base
    );
  }

  // ==========================================================================
  // CRÉER UNE COPIE MODIFIÉE DE L'UTILISATEUR
  // ==========================================================================
  // Cette fonction crée un nouvel utilisateur identique à l'actuel
  // mais avec certains champs modifiés
  // C'est utile car les propriétés sont "final" (non modifiables)
  // Exemple : pour changer juste l'email sans toucher au reste
  // ==========================================================================
  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
  }) {
    // ========================================================================
    // CRÉER UN NOUVEL UTILISATEUR
    // ========================================================================
    // Pour chaque champ, on utilise l'opérateur ??
    // ?? signifie : "si la nouvelle valeur est fournie, l'utiliser,
    //                sinon garder l'ancienne valeur (this.xxx)"
    return User(
      id: id ?? this.id,
      // Si on fournit un nouvel id, on l'utilise
      // Sinon, on garde l'ancien id (this.id)
      
      nom: nom ?? this.nom,
      // Même principe pour tous les autres champs
      
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
    );
  }

  // ==========================================================================
  // REPRÉSENTATION EN STRING POUR LE DÉBOGAGE
  // ==========================================================================
  // Cette fonction définit comment afficher un utilisateur en texte
  // Très utile pour déboguer : print(user) affichera ces infos
  // IMPORTANT : On n'affiche PAS le mot de passe pour la sécurité !
  // @override = on remplace la fonction toString() par défaut de Dart
  // ==========================================================================
  @override
  String toString() {
    return 'User(id: $id, nom: $nom, prenom: $prenom, email: $email)';
  }

  // ==========================================================================
  // VÉRIFIER L'ÉGALITÉ ENTRE DEUX UTILISATEURS
  // ==========================================================================
  // Cette fonction définit quand deux utilisateurs sont considérés comme égaux
  // Deux utilisateurs sont égaux s'ils ont le même ID
  // C'est logique : l'ID est unique, donc même ID = même personne !
  // @override = on remplace l'opérateur == par défaut
  // ==========================================================================
  @override
  bool operator ==(Object other) {
    // ========================================================================
    // VÉRIFIER SI C'EST EXACTEMENT LE MÊME OBJET EN MÉMOIRE
    // ========================================================================
    // identical() vérifie si c'est le même objet (même adresse mémoire)
    if (identical(this, other)) return true;
    
    // ========================================================================
    // VÉRIFIER SI L'AUTRE OBJET EST UN USER AVEC LE MÊME ID
    // ========================================================================
    // other is User = vérifier que other est bien de type User
    // other.id == id = vérifier que les IDs sont identiques
    return other is User && other.id == id;
  }

  // ==========================================================================
  // HASH CODE BASÉ SUR L'ID
  // ==========================================================================
  // Le hashCode est un nombre qui représente l'objet
  // Nécessaire pour utiliser User dans des Set ou comme clé de Map
  // Règle : si deux objets sont égaux (==), ils doivent avoir le même hashCode
  // C'est pourquoi on base le hashCode sur l'id (qui détermine l'égalité)
  // ==========================================================================
  @override
  int get hashCode => id.hashCode;

  // ==========================================================================
  // OBTENIR LE NOM COMPLET
  // ==========================================================================
  // Ce getter retourne le nom complet de l'utilisateur
  // C'est un raccourci pratique pour afficher le nom dans l'interface
  // get = on peut l'utiliser comme une propriété : user.nomComplet
  // ==========================================================================
  String get nomComplet => '$prenom $nom';
  // Exemple : si prenom = "Fabrice" et nom = "Kouassi"
  // nomComplet retournera "Fabrice Kouassi"

  // ==========================================================================
  // OBTENIR LES INITIALES
  // ==========================================================================
  // Ce getter retourne les initiales de l'utilisateur (première lettre de chaque nom)
  // Utile pour afficher un avatar avec des lettres par exemple
  // ==========================================================================
  String get initiales {
    // ========================================================================
    // RÉCUPÉRER LA PREMIÈRE LETTRE DU PRÉNOM
    // ========================================================================
    // On vérifie d'abord que prenom n'est pas vide
    // Si vide, on met une chaîne vide '', sinon on prend la première lettre [0]
    // toUpperCase() met la lettre en majuscule
    final firstLetter = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    
    // ========================================================================
    // RÉCUPÉRER LA PREMIÈRE LETTRE DU NOM
    // ========================================================================
    // Même principe que pour le prénom
    final lastLetter = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    
    // Retourner les deux lettres collées
    return '$firstLetter$lastLetter';
    // Exemple : "Fabrice Kouassi" → "FK"
  }
}
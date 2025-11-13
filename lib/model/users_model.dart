class User {
  int? id;
  String nom;
  String prenom;
  String email;
  String motDePasse;

  User({
    this.id, 
    required this.nom, 
    required this.prenom, 
    required this.email, 
    required this.motDePasse});
    
  User.sansId({
    required this.nom, 
    required this.prenom, 
    required this.email, 
    required this.motDePasse});

  // Convertir un objet Redacteur en Map pour l’enregistrement dans SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'password': motDePasse,
    };
  }

  // Définissez la méthode fromMap pour créer un Utilisateur à partir d'un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      motDePasse: map['password'],
    );
  }
}

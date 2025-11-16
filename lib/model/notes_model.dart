// ==============================================================================
// MODÈLE DE DONNÉES : NOTE
// ==============================================================================
// Cette classe représente une Note dans l'application
// C'est comme un plan ou un moule qui définit ce qu'est une note
// Chaque note a : un titre, un contenu, une couleur, une date, etc.
// ==============================================================================
class Note {
  // ==========================================================================
  // PROPRIÉTÉS D'UNE NOTE
  // ==========================================================================
  // Ce sont les informations que chaque note contient
  
  // L'ID unique de la note (comme un numéro de série)
  // Il est null lors de la création car il sera généré automatiquement par la base
  final int? id;
  
  // L'ID de l'utilisateur propriétaire de cette note
  // Permet de savoir à qui appartient la note
  final int? userId;
  
  // Le titre de la note (ex: "Liste de courses")
  final String title;
  
  // Le contenu de la note (le texte principal)
  final String content;
  
  // La couleur de la note, stockée sous forme de texte
  // (ex: "4294198070" qui correspond à une couleur)
  final String color;
  
  // La date et l'heure de création ou de dernière modification
  // Stockée sous forme de texte (ex: "2024-03-15 14:30:00")
  final String dateTime;

  // ==========================================================================
  // CONSTRUCTEUR : COMMENT CRÉER UNE NOTE
  // ==========================================================================
  // Le constructeur est comme une recette qui dit comment créer une note
  // Certains champs sont obligatoires (required), d'autres optionnels
  // ==========================================================================
  Note({
    this.id,           // Optionnel : null lors de la création
    this.userId,       // Optionnel : sera ajouté lors de l'enregistrement
    required this.title,    // Obligatoire : une note doit avoir un titre
    required this.color,    // Obligatoire : une note doit avoir une couleur
    required this.content,  // Obligatoire : une note doit avoir du contenu
    required this.dateTime, // Obligatoire : une note doit avoir une date
  });

  // ==========================================================================
  // CONVERTIR UNE NOTE EN MAP (DICTIONNAIRE)
  // ==========================================================================
  // Cette fonction transforme l'objet Note en Map (dictionnaire clé-valeur)
  // Pourquoi ? Parce que SQLite stocke les données sous forme de Map
  // C'est comme traduire notre note dans le langage de la base de données !
  // ==========================================================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,             // Clé 'id' → valeur de l'id
      'userId': userId,     // Clé 'userId' → valeur du userId
      'title': title,       // Clé 'title' → valeur du titre
      'content': content,   // Clé 'content' → valeur du contenu
      'color': color,       // Clé 'color' → valeur de la couleur
      'dateTime': dateTime, // Clé 'dateTime' → valeur de la date
    };
  }

  // ==========================================================================
  // CRÉER UNE NOTE À PARTIR D'UN MAP
  // ==========================================================================
  // Cette fonction fait l'inverse de toMap()
  // Elle prend un Map (récupéré de la base de données) et crée un objet Note
  // C'est comme traduire les données de la base en note utilisable !
  // factory = un type spécial de constructeur
  // ==========================================================================
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],           // Récupérer l'id depuis le Map
      userId: map['userId'],   // Récupérer le userId depuis le Map
      title: map['title'],     // Récupérer le titre depuis le Map
      color: map['color'],     // Récupérer la couleur depuis le Map
      content: map['content'], // Récupérer le contenu depuis le Map
      dateTime: map['dateTime'], // Récupérer la date depuis le Map
    );
  }

  // ==========================================================================
  // CRÉER UNE COPIE MODIFIÉE DE LA NOTE
  // ==========================================================================
  // Cette fonction crée une nouvelle note identique à l'actuelle
  // mais avec certains champs modifiés
  // C'est utile car les propriétés sont "final" (non modifiables)
  // Exemple : pour changer juste le titre sans toucher au reste
  // ==========================================================================
  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? color,
    String? dateTime,
  }) {
    // ========================================================================
    // CRÉER UNE NOUVELLE NOTE
    // ========================================================================
    // Pour chaque champ, on utilise l'opérateur ??
    // ?? signifie : "si la nouvelle valeur est fournie, l'utiliser,
    //                sinon garder l'ancienne valeur (this.xxx)"
    return Note(
      id: id ?? this.id,
      // Si on fournit un nouvel id, on l'utilise
      // Sinon, on garde l'ancien id (this.id)
      
      userId: userId ?? this.userId,
      // Même principe pour tous les autres champs
      
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
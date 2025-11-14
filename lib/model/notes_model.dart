/// Classe qui représente une Note dans l'application
/// Chaque note appartient à un utilisateur (via userId)
class Note {
  final int? id;           // ID unique de la note (null lors de la création)
  final int? userId;       // ID de l'utilisateur propriétaire de la note
  final String title;      // Titre de la note
  final String content;    // Contenu de la note
  final String color;      // Couleur de la note (stockée en String)
  final String dateTime;   // Date et heure de création/modification

  /// Constructeur de la classe Note
  Note({
    this.id,
    this.userId,
    required this.title,
    required this.color,
    required this.content,
    required this.dateTime,
  });

  /// Convertir un objet Note en Map (dictionnaire)
  /// Utilisé pour enregistrer la note dans la base de données SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'color': color,
      'dateTime': dateTime,
    };
  }

  /// Créer un objet Note à partir d'un Map
  /// Utilisé pour lire les notes depuis la base de données
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      color: map['color'],
      content: map['content'],
      dateTime: map['dateTime'],
    );
  }

  /// Créer une copie de la note avec des modifications
  /// Utile pour modifier certains champs sans changer les autres
  Note copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? color,
    String? dateTime,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
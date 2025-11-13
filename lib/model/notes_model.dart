class Note {
  final int? id;
  final String  title;
  final String content;
  final String color;
  final String dateTime;

  Note({
    this.id,
    required this.title,
    required this.color,
    required this.content,
    required this.dateTime
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'dateTime': dateTime,
    };
  }



  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
       color: map['color'], 
       content: map['content'], 
       dateTime: map['dateTime'],
       );
  }
}
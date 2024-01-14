const String tableSubject = 'subjects';
const String tableNotes = 'notes';

class SubjectFields {
  static final List<String> values = [id, subject];

  static const String id = '_id';
  static const String subject = 'subject';
}

class NoteFields {
  static final List<String> values = [
    id,
    subject,
    content,
  ];

  static const String id = '_id';
  static const String subject = 'subject';
  static const String content = 'content';

}

class Subject {
  final int? id;
  final String subject;

  Subject({
    this.id,
    required this.subject,
  });

  Subject copy({
    int? id,
    String? subject,
  }) =>
      Subject(
        id: id ?? this.id,
        subject: subject ?? this.subject,
      );

  static Subject fromJson(Map<String, dynamic> json) => Subject(
    id: json[SubjectFields.id],
    subject: json[SubjectFields.subject],
  );

  Map<String, dynamic> toJson() => {
    SubjectFields.id: id,
    SubjectFields.subject: subject,
  };
}

class Note {
  final int? id;
  final String subject;
  final String content;

  Note({
    this.id,
    required this.subject,
    required this.content,

  });

  Note copy({
    int? id,
    String? subject,
    String? content,

  }) =>
      Note(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        content: content ?? this.content,
      );

  static Note fromJson(Map<String, dynamic> json) => Note(
    id: json[NoteFields.id],
    subject: json[NoteFields.subject],
    content: json[NoteFields.content],
  );

  Map<String, dynamic> toJson() => {
    NoteFields.id: id,
    NoteFields.subject: subject,
    NoteFields.content: content,

  };
}
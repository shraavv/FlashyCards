import '../model/notes.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabase {
  NotesDatabase._privateConstructor();
  static final NotesDatabase instance = NotesDatabase._privateConstructor();

  static Database? _database;

  factory NotesDatabase() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'flashcards.db');

    return await openDatabase(
        path, version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN subject TEXT NOT NULL');
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSubject (
        ${SubjectFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SubjectFields.subject} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotes (
        ${NoteFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${NoteFields.subject} INTEGER NOT NULL,
        ${NoteFields.content} TEXT NOT NULL,
        FOREIGN KEY (${NoteFields.subject}) REFERENCES $tableSubject(${SubjectFields.id})
      )
    ''');
  }

  Future<Subject> createSubject(Subject subject) async {
    final db = await instance.database;
    final id = await db.insert(tableSubject, subject.toJson());
    return subject.copy(id: id);
  }

  Future<List<Subject>> readAllSubjects() async {
    final db = await instance.database;
    final result = await db.query(tableSubject);
    return result.map((json) => Subject.fromJson(json)).toList();
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id :id);
  }

  Future<List<Note>> readAllNotes() async{
    final db = await instance.database;
    final result = await db.query(tableNotes);
    return result.map((json) => Note.fromJson(json)).toList();
  }
}

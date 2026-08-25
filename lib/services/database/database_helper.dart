import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "aprende_mas.db";
  static const _databaseVersion = 4;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        author TEXT NOT NULL DEFAULT 'Desconocido',
        version TEXT NOT NULL DEFAULT '1.0',
        repository_id INTEGER DEFAULT NULL,
        repository_source TEXT NOT NULL DEFAULT 'joss-red'
      )
    ''');

    await db.execute('''
      CREATE TABLE modules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        short_description TEXT NOT NULL,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE submodules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content_md TEXT NOT NULL,
        FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE content_nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER NOT NULL,
        parent_id INTEGER,
        module_id INTEGER,
        title TEXT NOT NULL,
        content_md TEXT NOT NULL DEFAULT '',
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES content_nodes (id) ON DELETE CASCADE,
        FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        explanation_text TEXT NOT NULL,
        FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE test_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        module_id INTEGER NOT NULL,
        timestamp INT NOT NULL,
        score REAL NOT NULL,
        status TEXT NOT NULL,
        total_questions INTEGER NOT NULL DEFAULT 0,
        correct_answers INTEGER NOT NULL DEFAULT 0,
        current_question_index INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (module_id) REFERENCES modules (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_attempt_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        explanation_text TEXT,
        FOREIGN KEY (test_attempt_id) REFERENCES test_attempts (id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE subjects ADD COLUMN repository_id INTEGER DEFAULT NULL',
      );
    }
    if (oldVersion < 3) {
      await db.execute('''CREATE TABLE content_nodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER NOT NULL,
        parent_id INTEGER, module_id INTEGER, title TEXT NOT NULL,
        content_md TEXT NOT NULL DEFAULT '', sort_order INTEGER NOT NULL DEFAULT 0
      )''');
      final modules = await db.query('modules');
      for (final module in modules) {
        final moduleId = module['id'] as int;
        final subjectId = module['subject_id'] as int;
        final rootId = await db.insert('content_nodes', {
          'subject_id': subjectId,
          'module_id': moduleId,
          'title': module['title'],
          'sort_order': moduleId,
        });
        final lessons = await db.query(
          'submodules',
          where: 'module_id = ?',
          whereArgs: [moduleId],
        );
        for (var index = 0; index < lessons.length; index++) {
          await db.insert('content_nodes', {
            'subject_id': subjectId,
            'parent_id': rootId,
            'module_id': moduleId,
            'title': lessons[index]['title'],
            'content_md': lessons[index]['content_md'],
            'sort_order': index,
          });
        }
      }
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE subjects ADD COLUMN repository_source TEXT NOT NULL DEFAULT 'joss-red'",
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

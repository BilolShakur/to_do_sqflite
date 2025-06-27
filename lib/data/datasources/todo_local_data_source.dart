import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class TodoLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,
            dueDate TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  Future<List<TodoModel>> getTodos() async {
    final db = await database;
    final maps = await db.query('todos');
    return maps
        .map((map) => TodoModel(
              id: map['id'] as String,
              title: map['title'] as String,
              description: map['description'] as String,
              isCompleted: (map['isCompleted'] as int) == 1,
              dueDate: map['dueDate'] != null
                  ? DateTime.tryParse(map['dueDate'] as String)
                  : null,
              createdAt: DateTime.parse(map['createdAt'] as String),
              updatedAt: DateTime.parse(map['updatedAt'] as String),
            ))
        .toList();
  }

  Future<void> addTodo(TodoModel todo) async {
    final db = await database;
    await db.insert(
      'todos',
      {
        'id': todo.id,
        'title': todo.title,
        'description': todo.description,
        'isCompleted': todo.isCompleted ? 1 : 0,
        'dueDate': todo.dueDate?.toIso8601String(),
        'createdAt': todo.createdAt.toIso8601String(),
        'updatedAt': todo.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTodo(TodoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      {
        'title': todo.title,
        'description': todo.description,
        'isCompleted': todo.isCompleted ? 1 : 0,
        'dueDate': todo.dueDate?.toIso8601String(),
        'createdAt': todo.createdAt.toIso8601String(),
        'updatedAt': todo.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

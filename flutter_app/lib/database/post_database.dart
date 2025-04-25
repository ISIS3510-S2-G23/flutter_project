import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post_model.dart';

class PostDatabase {
  static final PostDatabase instance = PostDatabase._init();
  static Database? _database;

  PostDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ecosphere_posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        text TEXT NOT NULL,
        user TEXT NOT NULL,
        asset TEXT,
        upvotes INTEGER NOT NULL,
        upvotedBy TEXT,
        tags TEXT,
        comments TEXT
      )
    ''');
  }

  // Guardar posts en la base de datos
  Future<void> savePosts(List<PostModel> posts) async {
    final db = await database;

    // Borrar los anteriores antes de insertar los nuevos
    await db.delete('posts');

    // Insertar usando transacción para mejor rendimiento
    await db.transaction((txn) async {
      for (var post in posts) {
        await txn.insert(
          'posts',
          post.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Obtener todos los posts
  Future<List<PostModel>> getPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('posts');

    return List.generate(maps.length, (i) {
      return PostModel.fromMap(maps[i]);
    });
  }

  // Buscar posts por texto en título o contenido
  Future<List<PostModel>> searchPosts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'title LIKE ? OR text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return PostModel.fromMap(maps[i]);
    });
  }

  // Filtrar posts por tag
  Future<List<PostModel>> getPostsByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );

    return List.generate(maps.length, (i) {
      return PostModel.fromMap(maps[i]);
    });
  }
}
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rewards.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE challenges (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            reward TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE users_challenges (
            id TEXT PRIMARY KEY,
            challenge_id TEXT,
            user TEXT,
            completed INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertOrUpdateChallenge(Map<String, dynamic> challenge) async {
    final dbClient = await db;
    await dbClient.insert('challenges', challenge,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrUpdateUserChallenge(
      Map<String, dynamic> userChallenge) async {
    final dbClient = await db;
    await dbClient.insert('users_challenges', userChallenge,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getChallenges() async {
    final dbClient = await db;
    return await dbClient.query('challenges');
  }

  Future<Map<String, dynamic>?> getUserChallenge(
      String challengeId, String user) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users_challenges',
      where: 'challenge_id = ? AND user = ?',
      whereArgs: [challengeId, user],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

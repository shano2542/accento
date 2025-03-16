import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'recordings.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recordings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name Text NOT NULL,
            file_path TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertRecording(String name, String filePath) async {
    final db = await database;
    return await db.insert('recordings', {
      'name': name,
      'file_path': filePath,
      'created_at': DateTime.now().toIso8601String()
    });
  }

  Future<List<Map<String, dynamic>>> fetchRecordings() async {
    final db = await database;
    return await db.query('recordings', orderBy: 'name DESC');
  }

  Future<List<Map<String, dynamic>>> getAllRecordings() async {  // Renamed method
    final db = await database;
    return await db.query('recordings', orderBy: 'name DESC');
  }

  Future<int> deleteRecording(int id) async {
    final db = await database;

    // Fetch the file path before deleting from the database
    List<Map<String, dynamic>> result = await db.query(
      'recordings',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      String filePath = result.first['file_path'];

      // Delete the audio file from storage
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from database
      return await db.delete('recordings', where: 'id = ?', whereArgs: [id]);
    }

    return 0; // If recording doesn't exist
  } 
}


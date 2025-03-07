import 'package:flutter_sqlite_demo/models/dog.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  // Singleton pattern
  Database? _database;
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the path to the database.
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'doggie_database.db');

    // Open the database and create the table if it doesn't exist.
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertDog(Dog dog) async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Insert the Dog into the appropriate table.
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> retrieveDogs() async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Query the table for all Dogs.
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic>> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(id: maps[i]['id'], name: maps[i]['name'], age: maps[i]['age']);
    });
  }

  Future<void> updateDog(Dog dog) async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Update the given Dog.
    await db.update('dogs', dog.toMap(), where: 'id = ?', whereArgs: [dog.id]);
  }

  Future<void> deleteDog(int? id) async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Delete the Dog with the specified id.
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/users.dart';

class DatabaseHelper {
  final databaseName = "tugas3.db";
  String users =
      "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(users);
      },
    );
  }

  Future<Map<String, dynamic>> login(Users user) async {
    final Database db = await initDB();

    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user.username, user.password],
    );

    if (result.isNotEmpty) {
      return {
        'success': true,
        'userId': result.first['id'],
        'username': result.first['username'],
      };
    } else {
      return {'success': false, 'userId': null, 'username': null};
    }
  }

  Future<int> signup(Users user) async {
    final Database db = await initDB();

    return db.insert('users', user.toMap());
  }
}

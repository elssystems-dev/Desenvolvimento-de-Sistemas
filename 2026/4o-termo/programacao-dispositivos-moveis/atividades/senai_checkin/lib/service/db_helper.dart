import 'package:senai_checkin/model/user_logs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:senai_checkin/service/sql/create_tables.dart';
import 'package:path/path.dart';

class DbHelper {

  // Arquitetura Singleton
  DbHelper._internal();
  static final DbHelper _db = DbHelper._internal();
  factory DbHelper() => _db;

  Database? _dbConnector;

  Future<Database> get dbConnector async {
    if (_dbConnector != null) return _dbConnector!;
    _dbConnector = await _initDb();
    return _dbConnector!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), "senai_checkin_db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(createLogScript);
      }
    );
  }

  Future<<List<UserLogs>>> getLogs() async {
    final List<Map<String, dynamic>> maps = await (await dbConnector).query(
      "user_logs",
      orderBy: "id DESC"
    );
    return List.generate(maps.length, (e) => UserLogs.fromMap(maps[e]));
  }

}
import 'dart:async';
import 'dart:io';
import 'package:melyj/model/audio_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/windows/sqflite_ffi_setup.dart';


class DatabaseHelper {
  // singleton
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> getDataBase() async {
    if (_database != null) {
      return _database!;
    } else {
      // La base de datos no esta inicializada
      _database = await initDB("playoor.db");
      return _database!;
    }
  }

  Future<Database?> initDB(String filePath) async {
    String dbPath, path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      dbPath = await databaseFactoryFfi.getDatabasesPath();
      path = join(dbPath, filePath);
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: onCreate),
      );
    }
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: onCreate);
    }
  }

  FutureOr<void> onCreate(Database db, int version) async {
    return await db.execute("""
    create table songs (
    id integer primary key autoincrement,
    assetPath varchar(50) not null,
    title varchar(40) not null,
    artist varchar(40) not null,
    imagePath varchar(50) not null
    );     
    """);
  }

  // Crud
  Future<AudioItem> Create(AudioItem audioitem) async {
    final db = await instance.getDataBase();
    int newId = await db.insert('songs', audioitem.toMap());
    final result = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [newId],
      limit: 1,
    );
    return AudioItem.fromMap(result.first);
  }

  Future<List<AudioItem>> ReadAll() async {
    final db = await instance.getDataBase();
    final data = await db.query('songs', orderBy: 'id ASC');
    return data.map((map) => AudioItem.fromMap(map)).toList();
  }

  // Eliminar una canción específica por ID
  Future<int> Delete(int id) async {
    final db = await instance.getDataBase();
    return await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Eliminar todas las canciones
  Future<int> DeleteAll() async {
    final db = await instance.getDataBase();
    return await db.delete('songs');
  }

  // Actualizar una canción
  Future<int> Update(AudioItem audioitem) async {
    final db = await instance.getDataBase();
    return await db.update(
      'songs',
      audioitem.toMap(),
      where: 'id = ?',
      whereArgs: [audioitem.id],
    );
  }

  // Obtener una canción por ID
  Future<AudioItem?> ReadById(int id) async {
    final db = await instance.getDataBase();
    final result = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return AudioItem.fromMap(result.first);
    }
    return null;
  }

  void Close() async {
    final db = await instance.getDataBase();
    db.close();
  }
} // end class
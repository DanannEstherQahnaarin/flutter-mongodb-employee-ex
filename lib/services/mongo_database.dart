import 'dart:developer';
import 'dart:io'; // Platform 체크를 위해 추가
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MongoDatabase {
  static final MongoDatabase _instance = MongoDatabase._internal();
  factory MongoDatabase() => _instance;
  MongoDatabase._internal();

  static Db? _db;
  static DbCollection? _employeeCollection;

  DbCollection get employeeCollection {
    if (_employeeCollection == null) {
      throw Exception('Database is not initialized. Call connect() first.');
    }
    return _employeeCollection!;
  }

  Future<void> connect() async {
    try {
      await dotenv.load();
      String? connectionUrl = dotenv.env['MONGO_CONN_URL'];

      if (connectionUrl == null) {
        throw Exception('MONGO_CONN_URL not found in .env file');
      }

      // 📱 안드로이드 에뮬레이터 대응 로직 추가
      // 안드로이드에서는 localhost(127.0.0.1) 대신 10.0.2.2를 사용해야 호스트 PC에 접근 가능
      if (Platform.isAndroid) {
        connectionUrl = connectionUrl.replaceFirst('127.0.0.1', '10.0.2.2');
        log("📱 Android Emulator Detected: Switching to 10.0.2.2");
      }

      _db = await Db.create(connectionUrl);
      await _db!.open();

      inspect(_db);
      log("✅ MongoDB Connected Successfully!");

      _employeeCollection = _db!.collection('employees');
    } catch (e) {
      log("❌ MongoDB Connection Error: $e");
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      log("🔒 MongoDB Connection Closed.");
    }
  }
}

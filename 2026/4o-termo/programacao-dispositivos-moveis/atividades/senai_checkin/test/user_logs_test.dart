import 'package:flutter_test/flutter_test.dart';
import 'package:senai_checkin/model/user_logs.dart';
import 'package:senai_checkin/service/sql/create_tables.dart';

void main() {
  group('UserLogs Model Tests', () {
    test('Deve serializar e desserializar UserLogs corretamente', () {
      final now = DateTime(2026, 9, 24, 14, 30);
      final log = UserLogs(
        id: 1,
        createdAt: now,
        mediaPath: '/path/to/foto.jpg',
        latitude: -23.55052,
        longitude: -46.633308,
        notes: 'Visita técnica no laboratório',
      );

      final map = log.toMap();
      expect(map['id'], 1);
      expect(map['created_at'], now.toIso8601String());
      expect(map['media_path'], '/path/to/foto.jpg');
      expect(map['latitude'], -23.55052);
      expect(map['longitude'], -46.633308);
      expect(map['notes'], 'Visita técnica no laboratório');

      final fromMapLog = UserLogs.fromMap(map);
      expect(fromMapLog.id, 1);
      expect(fromMapLog.createdAt, now);
      expect(fromMapLog.mediaPath, '/path/to/foto.jpg');
      expect(fromMapLog.latitude, -23.55052);
      expect(fromMapLog.longitude, -46.633308);
      expect(fromMapLog.notes, 'Visita técnica no laboratório');
    });

    test('Deve formatar a data e hora corretamente', () {
      final date = DateTime(2026, 9, 24, 8, 45);
      final log = UserLogs(
        createdAt: date,
        mediaPath: '/img.jpg',
        latitude: -22.0,
        longitude: -47.0,
      );

      expect(log.formattedDate, '24/09/2026 às 08:45');
    });

    test('Valida script SQL da tabela user_logs', () {
      expect(createLogScript.contains('CREATE TABLE IF NOT EXISTS user_logs'), isTrue);
      expect(createLogScript.contains('id INTEGER PRIMARY KEY AUTOINCREMENT,'), isTrue);
      expect(createLogScript.contains('created_at TEXT NOT NULL,'), isTrue);
      expect(createLogScript.contains('media_path TEXT NOT NULL,'), isTrue);
      expect(createLogScript.contains('latitude REAL NOT NULL CHECK'), isTrue);
      expect(createLogScript.contains('longitude REAL NOT NULL CHECK'), isTrue);
      expect(createLogScript.contains('notes TEXT'), isTrue);
    });
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiksha_saathi/core/services/offline_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineSyncService Data & Status Tests', () {
    test('Offline payload serialization and parsing', () {
      final payload = {
        'actionType': 'ATTENDANCE_MARK',
        'endpoint': '/teacher/classes/c1/attendance',
        'method': 'POST',
        'data': {
          'date': '2026-09-08',
          'attendanceList': [
            {'student_id': 's1', 'status': 'present'},
            {'student_id': 's2', 'status': 'absent'},
          ],
        },
        'createdAt': DateTime.now().toIso8601String(),
      };

      final encoded = jsonEncode(payload);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      expect(decoded['actionType'], 'ATTENDANCE_MARK');
      expect(decoded['method'], 'POST');
      expect((decoded['data']['attendanceList'] as List).length, 2);
    });

    test('SyncStatus enum values exist', () {
      expect(SyncStatus.values.contains(SyncStatus.idle), isTrue);
      expect(SyncStatus.values.contains(SyncStatus.syncing), isTrue);
      expect(SyncStatus.values.contains(SyncStatus.offline), isTrue);
      expect(SyncStatus.values.contains(SyncStatus.error), isTrue);
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';

enum SyncStatus { idle, syncing, offline, error }

class OfflineSyncService {
  static final OfflineSyncService instance = OfflineSyncService._();
  OfflineSyncService._();

  static const String boxName = 'shiksha_offline_queue';
  Box? _box;
  final ValueNotifier<int> pendingCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<SyncStatus> statusNotifier = ValueNotifier<SyncStatus>(SyncStatus.idle);
  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);

  StreamSubscription? _connectivitySubscription;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
    _updatePendingCount();

    // Check initial connectivity
    final connectivityResults = await Connectivity().checkConnectivity();
    _updateOnlineStatus(connectivityResults);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateOnlineStatus(results);
      if (isOnlineNotifier.value && pendingCountNotifier.value > 0) {
        syncPending();
      }
    });
  }

  void _updateOnlineStatus(dynamic results) {
    bool online = false;
    if (results is List<ConnectivityResult>) {
      online = results.any((r) => r != ConnectivityResult.none);
    } else if (results is ConnectivityResult) {
      online = results != ConnectivityResult.none;
    }
    isOnlineNotifier.value = online;
    if (!online) {
      statusNotifier.value = SyncStatus.offline;
    } else if (statusNotifier.value == SyncStatus.offline) {
      statusNotifier.value = SyncStatus.idle;
    }
  }

  void _updatePendingCount() {
    pendingCountNotifier.value = _box?.length ?? 0;
  }

  Future<void> enqueue({
    required String actionType,
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
  }) async {
    if (_box == null) await init();
    final item = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'actionType': actionType,
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _box!.add(jsonEncode(item));
    _updatePendingCount();

    if (isOnlineNotifier.value) {
      syncPending();
    }
  }

  Future<void> syncPending() async {
    if (_box == null || _box!.isEmpty || !isOnlineNotifier.value) return;
    if (statusNotifier.value == SyncStatus.syncing) return;

    statusNotifier.value = SyncStatus.syncing;
    final keys = _box!.keys.toList();

    for (final key in keys) {
      final raw = _box!.get(key);
      if (raw == null) continue;

      try {
        final item = jsonDecode(raw.toString()) as Map<String, dynamic>;
        final method = item['method']?.toString().toUpperCase() ?? 'POST';
        final endpoint = item['endpoint']?.toString() ?? '';
        final data = item['data'];

        if (method == 'POST') {
          await ApiClient.instance.post(endpoint, data: data);
        } else if (method == 'PUT') {
          await ApiClient.instance.put(endpoint, data: data);
        } else if (method == 'PATCH') {
          await ApiClient.instance.patch(endpoint, data: data);
        }

        await _box!.delete(key);
        _updatePendingCount();
      } catch (e) {
        debugPrint('Failed to sync offline item: $e');
        statusNotifier.value = SyncStatus.error;
        return;
      }
    }

    _updatePendingCount();
    statusNotifier.value = SyncStatus.idle;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

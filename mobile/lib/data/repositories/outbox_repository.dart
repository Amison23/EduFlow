import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../local/daos/outbox_dao.dart';
import '../local/database.dart';

/// Repository for managing the generic outbox sync
class OutboxRepository {
  final AppDatabase _localDatabase;
  final ApiClient _apiClient = ApiClient();
  final ConnectivityService _connectivityService = ConnectivityService();
  final _uuid = const Uuid();

  OutboxRepository({required AppDatabase localDatabase}) : _localDatabase = localDatabase;

  /// Enqueue a request to the outbox
  Future<void> enqueueRequest({
    required String url,
    required String method,
    required Map<String, dynamic> body,
  }) async {
    final outboxDao = OutboxDao(_localDatabase);
    await outboxDao.insertRequest(
      id: _uuid.v4(),
      url: url,
      method: method,
      body: jsonEncode(body),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Process all pending requests in the outbox
  Future<int> processOutbox() async {
    if (!_connectivityService.isOnline) return 0;

    final outboxDao = OutboxDao(_localDatabase);
    final requests = await outboxDao.getPendingRequests();
    
    int successCount = 0;
    for (final request in requests) {
      final success = await _dispatchRequest(
        url: request['url'],
        method: request['method'],
        body: jsonDecode(request['body']),
      );

      if (success) {
        await outboxDao.deleteRequest(request['id']);
        successCount++;
      } else {
        await outboxDao.incrementRetryCount(request['id']);
        // If one fails due to server error, maybe stop processing further for now
        // to avoid cascading failures if the server is down.
        // For simplicity, we continue with others unless it's a critical error.
      }
    }
    
    return successCount;
  }

  /// Dispatch a single request
  Future<bool> _dispatchRequest({
    required String url,
    required String method,
    required dynamic body,
  }) async {
    try {
      if (method == 'POST') {
        await _apiClient.post(url, data: body);
      } else if (method == 'PUT') {
        await _apiClient.put(url, data: body);
      } else if (method == 'PATCH') {
        await _apiClient.patch(url, data: body);
      } else if (method == 'DELETE') {
        await _apiClient.delete(url, data: body);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get total pending requests
  Future<int> getPendingCount() async {
    final outboxDao = OutboxDao(_localDatabase);
    return await outboxDao.getPendingCount();
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor and manage network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _connectivityController = StreamController<bool>.broadcast();
  
  /// Stream of connectivity status (true = online, false = offline)
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  /// Current connectivity status
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isOnline = _hasActiveConnection(results);
    _connectivityController.add(_isOnline);
    
    if (kDebugMode) {
      print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
    }
  }

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Check for any active connection
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }
    return false;
  }

  /// Check if we have mobile data connection
  bool hasMobileData(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile);
  }

  /// Check if we have wifi connection
  bool hasWifi(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi);
  }

  /// Manually trigger a connectivity check
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    return _isOnline;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

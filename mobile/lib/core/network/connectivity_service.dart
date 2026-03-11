import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor and manage network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<ConnectivityResult>? _subscription;
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
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _checkConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isOnline = _hasActiveConnection(result);
    _connectivityController.add(_isOnline);
    
    if (kDebugMode) {
      print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
    }
  }

  bool _hasActiveConnection(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Check if we have mobile data connection
  bool hasMobileData(ConnectivityResult result) {
    return result == ConnectivityResult.mobile;
  }

  /// Check if we have wifi connection
  bool hasWifi(ConnectivityResult result) {
    return result == ConnectivityResult.wifi;
  }

  /// Manually trigger a connectivity check
  Future<bool> checkConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

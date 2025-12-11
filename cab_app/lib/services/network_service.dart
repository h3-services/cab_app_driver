import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();
  
  StreamController<bool>? _networkController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;
  
  bool _isConnected = true;
  Function()? _showNoInternetPage;
  Function()? _resumeApp;
  bool _isInitialized = false;

  Stream<bool> get networkStream {
    if (_networkController == null) {
      _networkController = StreamController<bool>.broadcast();
    }
    return _networkController!.stream;
  }
  
  bool get isConnected => _isConnected;

  void initialize({
    required Function() showNoInternetPage,
    required Function() resumeApp,
  }) {
    if (_isInitialized) return;
    
    _showNoInternetPage = showNoInternetPage;
    _resumeApp = resumeApp;
    
    if (_networkController == null) {
      _networkController = StreamController<bool>.broadcast();
    }
    
    _startListening();
    _isInitialized = true;
  }

  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _internetSubscription = _internetChecker.onStatusChange.listen(_onInternetStatusChanged);
    _checkInitialConnection();
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _updateConnectionStatus(false);
    } else {
      _internetChecker.hasConnection.then(_updateConnectionStatus);
    }
  }

  void _onInternetStatusChanged(InternetConnectionStatus status) {
    _updateConnectionStatus(status == InternetConnectionStatus.connected);
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      
      if (_networkController != null && !_networkController!.isClosed) {
        _networkController!.add(isConnected);
      }
      
      if (isConnected) {
        _resumeApp?.call();
      } else {
        _showNoInternetPage?.call();
      }
    }
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _updateConnectionStatus(false);
    } else {
      final hasInternet = await _internetChecker.hasConnection;
      _updateConnectionStatus(hasInternet);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    if (_networkController != null && !_networkController!.isClosed) {
      _networkController!.close();
    }
    _isInitialized = false;
  }
}
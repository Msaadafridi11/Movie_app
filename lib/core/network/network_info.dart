import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final results = await connectivity.checkConnectivity();
      if (results.isEmpty) return false;
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      // In case of platform exception, assume connected so Dio can attempt the call
      return true;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) {
      if (results.isEmpty) return false;
      return !results.contains(ConnectivityResult.none);
    });
  }
}

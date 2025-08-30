abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // Simple network check - can be enhanced with connectivity_plus package
    return true; // For now, assume connected
  }
}

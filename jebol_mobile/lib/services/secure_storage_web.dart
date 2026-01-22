/// Web implementation: in-memory storage for session lifetime.
class SecureStorage {
  // keep store static so it survives across instances during app lifetime
  static final Map<String, String?> _store = <String, String?>{};

  const SecureStorage();

  Future<void> write({required String key, required String? value}) async {
    _store[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _store[key];
  }

  Future<void> delete({required String key}) async {
    _store.remove(key);
  }
}

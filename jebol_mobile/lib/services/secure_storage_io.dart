import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mobile/desktop implementation using `flutter_secure_storage`.
class SecureStorage {
  final FlutterSecureStorage _impl;

  const SecureStorage([FlutterSecureStorage? impl]) : _impl = impl ?? const FlutterSecureStorage();

  Future<void> write({required String key, required String? value}) {
    return _impl.write(key: key, value: value);
  }

  Future<String?> read({required String key}) {
    return _impl.read(key: key);
  }

  Future<void> delete({required String key}) {
    return _impl.delete(key: key);
  }
}

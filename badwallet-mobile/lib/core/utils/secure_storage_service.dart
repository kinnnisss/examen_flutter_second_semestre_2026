import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Fine surcouche autour de [FlutterSecureStorage] pour le stockage sécurisé
/// (numéro de wallet courant, et plus tard un éventuel token).
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> clear() => _storage.deleteAll();
}

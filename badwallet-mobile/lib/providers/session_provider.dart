import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/secure_storage_service.dart';

/// État de session de l'utilisateur courant.
///
/// BadWallet identifie un wallet par son numéro de téléphone. On conserve ici
/// le numéro courant (et le code wallet) de façon sécurisée via
/// [SecureStorageService]. Aucune donnée mockée : ces valeurs sont saisies par
/// l'utilisateur dans la future page Auth puis réutilisées par les écrans.
class SessionProvider extends ChangeNotifier {
  SessionProvider(this._storage);

  final SecureStorageService _storage;

  String? _phoneNumber;
  String? _walletCode;
  bool _initialized = false;

  String? get phoneNumber => _phoneNumber;
  String? get walletCode => _walletCode;
  bool get isInitialized => _initialized;
  bool get isLoggedIn => _phoneNumber != null && _phoneNumber!.isNotEmpty;

  /// Charge la session persistée au démarrage de l'application.
  Future<void> load() async {
    _phoneNumber = await _storage.read(AppConstants.storageKeyPhone);
    _walletCode = await _storage.read(AppConstants.storageKeyWalletCode);
    _initialized = true;
    notifyListeners();
  }

  /// Définit le wallet courant (appelé après identification).
  Future<void> setSession({
    required String phoneNumber,
    String? walletCode,
  }) async {
    _phoneNumber = phoneNumber;
    _walletCode = walletCode;
    await _storage.write(AppConstants.storageKeyPhone, phoneNumber);
    if (walletCode != null) {
      await _storage.write(AppConstants.storageKeyWalletCode, walletCode);
    }
    notifyListeners();
  }

  /// Termine la session.
  Future<void> clear() async {
    _phoneNumber = null;
    _walletCode = null;
    await _storage.delete(AppConstants.storageKeyPhone);
    await _storage.delete(AppConstants.storageKeyWalletCode);
    notifyListeners();
  }
}

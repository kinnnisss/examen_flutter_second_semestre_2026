import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/error_messages.dart';
import '../core/utils/formatters.dart';
import '../core/utils/secure_storage_service.dart';
import '../services/wallet_service.dart';

/// Gère l'identité du client (login simulé basé sur le numéro de téléphone).
///
/// Pas d'authentification JWT : on vérifie simplement que le wallet existe
/// côté API, puis on persiste le numéro dans le stockage sécurisé. Le numéro
/// de téléphone est l'identifiant principal du client.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required SecureStorageService storage,
    required WalletService walletService,
  }) : _storage = storage,
       _walletService = walletService;

  final SecureStorageService _storage;
  final WalletService _walletService;

  String? _phoneNumber;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  String? get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _phoneNumber != null && _phoneNumber!.isNotEmpty;

  /// Charge le numéro persisté au démarrage (appelé par le Splash).
  Future<void> loadSession() async {
    _phoneNumber = await _storage.read(AppConstants.storageKeyPhone);
    _isInitialized = true;
    notifyListeners();
  }

  /// Login simulé : normalise le numéro, vérifie l'existence du wallet via
  /// `GET /api/wallets/{phone}`, puis persiste le numéro.
  ///
  /// Retourne `true` en cas de succès. En cas d'échec, [error] est renseigné.
  Future<bool> login(String rawPhone) async {
    final phone = Formatters.toApiPhone(rawPhone);
    if (phone == null) {
      _error = 'Numéro de téléphone invalide.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifie que le wallet existe réellement (404 sinon).
      final wallet = await _walletService.getWallet(phone);

      await _storage.write(AppConstants.storageKeyPhone, wallet.phoneNumber);
      await _storage.write(
        AppConstants.storageKeyWalletCode,
        wallet.code,
      );
      _phoneNumber = wallet.phoneNumber;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = ErrorMessages.from(e);
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion : efface le numéro persisté.
  Future<void> logout() async {
    _phoneNumber = null;
    _error = null;
    await _storage.delete(AppConstants.storageKeyPhone);
    await _storage.delete(AppConstants.storageKeyWalletCode);
    notifyListeners();
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

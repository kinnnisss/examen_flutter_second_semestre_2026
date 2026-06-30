import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/error_messages.dart';
import '../core/utils/formatters.dart';
import '../core/utils/secure_storage_service.dart';
import '../services/wallet_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required SecureStorageService storage,
    required WalletService walletService,
  }) : _storage = storage,
       _walletService = walletService;

  final SecureStorageService _storage;
  final WalletService _walletService;

  String? _phoneNumber;
  String? _walletCode;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  String? get phoneNumber => _phoneNumber;
  String? get walletCode => _walletCode;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _phoneNumber != null && _phoneNumber!.isNotEmpty;

  Future<void> loadSession() async {
    _phoneNumber = await _storage.read(AppConstants.storageKeyPhone);
    _walletCode = await _storage.read(AppConstants.storageKeyWalletCode);
    _isInitialized = true;
    notifyListeners();
  }

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
      final wallet = await _walletService.getWallet(phone);

      await _storage.write(AppConstants.storageKeyPhone, wallet.phoneNumber);
      await _storage.write(AppConstants.storageKeyWalletCode, wallet.code);
      _phoneNumber = wallet.phoneNumber;
      _walletCode = wallet.code;
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

  Future<void> logout() async {
    _phoneNumber = null;
    _walletCode = null;
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

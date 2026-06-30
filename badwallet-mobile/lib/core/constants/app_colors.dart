import 'package:flutter/material.dart';

/// Palette de couleurs de BadWallet.
///
/// Inspirée des wallets modernes (Wave / Orange Money / PayPal) : un violet
/// profond comme couleur principale, un accent cyan/teal et des couleurs
/// sémantiques cohérentes.
class AppColors {
  const AppColors._();

  // Marque
  static const Color primary = Color(0xFF5B2EFF); // violet électrique
  static const Color primaryDark = Color(0xFF3D1FB0);
  static const Color primaryLight = Color(0xFFEDE7FF);
  static const Color accent = Color(0xFF00C2A8); // teal

  // Sémantique
  static const Color success = Color(0xFF1FB266);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF2D7FF9);

  // Neutres
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111322);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color disabled = Color(0xFFC4C7D0);

  /// Couleurs des montants entrants / sortants dans l'historique.
  static const Color amountIn = success;
  static const Color amountOut = error;
}

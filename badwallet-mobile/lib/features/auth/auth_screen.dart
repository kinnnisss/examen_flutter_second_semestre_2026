import 'package:flutter/material.dart';

import '../_shared/placeholder_screen.dart';

/// Page d'authentification (saisie du numéro de wallet). Placeholder du lot 1.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Connexion',
      icon: Icons.account_balance_wallet_rounded,
      description:
          'Identification du wallet par numéro de téléphone (+221...). '
          'Le formulaire réel sera ajouté au prochain lot.',
    );
  }
}

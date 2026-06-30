import 'package:flutter/material.dart';

import '../_shared/placeholder_screen.dart';

/// Page d'historique des transactions. Placeholder du lot 1.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Historique',
      icon: Icons.history_rounded,
      description:
          'Liste des transactions du wallet '
          '(GET /api/wallets/{phoneNumber}/transactions).',
    );
  }
}

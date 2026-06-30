import 'package:flutter/material.dart';

import '../_shared/placeholder_screen.dart';

/// Page de transfert d'argent. Placeholder du lot 1.
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Transfert',
      icon: Icons.send_rounded,
      description:
          'Envoi d\'argent vers un autre wallet '
          '(POST /api/wallets/transfer).',
    );
  }
}

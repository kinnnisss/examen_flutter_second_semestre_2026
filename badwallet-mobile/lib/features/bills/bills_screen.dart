import 'package:flutter/material.dart';

import '../_shared/placeholder_screen.dart';

/// Page des factures externes. Placeholder du lot 1.
class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Factures',
      icon: Icons.receipt_long_rounded,
      description:
          'Consultation et paiement des factures '
          '(GET /api/external/factures/{walletCode}/current).',
    );
  }
}

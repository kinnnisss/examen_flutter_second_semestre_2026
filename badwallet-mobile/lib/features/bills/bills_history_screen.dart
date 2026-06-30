import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../history/transaction_tile.dart';

class BillsHistoryScreen extends StatefulWidget {
  const BillsHistoryScreen({super.key});

  @override
  State<BillsHistoryScreen> createState() => _BillsHistoryScreenState();
}

class _BillsHistoryScreenState extends State<BillsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final phone = context.read<AuthProvider>().phoneNumber;
    if (phone != null) {
      await context.read<HistoryProvider>().refresh(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final payments = history.billPayments;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des factures')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: _buildBody(history, payments.isEmpty),
        ),
      ),
    );
  }

  Widget _buildBody(HistoryProvider history, bool isEmpty) {
    if (history.isLoading && !history.hasData) {
      return const AppLoader(message: 'Chargement des paiements...');
    }

    if (isEmpty) {
      return _scrollable(
        const EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'Aucun paiement de facture',
          message: 'Les débits de type BILL_PAYMENT apparaîtront ici.',
        ),
      );
    }

    final payments = history.billPayments;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      itemCount: payments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => TransactionTile(transaction: payments[i]),
    );
  }

  Widget _scrollable(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

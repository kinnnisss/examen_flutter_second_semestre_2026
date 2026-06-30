import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'transaction_tile.dart';

/// Onglet "Historique" : liste complète des transactions du wallet.
///
/// Réutilise [DashboardProvider] qui détient déjà la liste complète
/// (GET /api/wallets/{phone}/transactions). Pull-to-refresh disponible.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    final phone = context.read<AuthProvider>().phoneNumber;
    if (phone != null) {
      await context.read<DashboardProvider>().refresh(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(context),
          child: _buildBody(context, dashboard),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardProvider dashboard) {
    if (dashboard.isLoading && !dashboard.hasData) {
      return const AppLoader(message: 'Chargement de l\'historique...');
    }

    if (dashboard.error != null && !dashboard.hasData) {
      return _scrollable(
        AppErrorState(
          message: dashboard.error!,
          onRetry: () => _refresh(context),
        ),
      );
    }

    final transactions = dashboard.transactions;
    if (transactions.isEmpty) {
      return _scrollable(
        const EmptyState(
          icon: Icons.history_rounded,
          title: 'Aucune transaction',
          message: 'Vos opérations apparaîtront ici.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => TransactionTile(transaction: transactions[i]),
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

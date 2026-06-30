import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/wallet_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../history/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceHidden = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final phone = context.read<AuthProvider>().phoneNumber;
    if (phone != null) {
      await context.read<DashboardProvider>().refresh(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final phone = context.watch<AuthProvider>().phoneNumber ?? '';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: _buildBody(context, dashboard, phone),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DashboardProvider dashboard,
    String phone,
  ) {

    if (dashboard.error != null && !dashboard.hasData) {
      return _scrollable(
        AppErrorState(message: dashboard.error!, onRetry: _load),
      );
    }

    if (dashboard.isLoading && !dashboard.hasData) {
      return _scrollable(const AppLoader(message: 'Chargement du wallet...'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        _Greeting(phone: phone),
        const SizedBox(height: AppConstants.spacingMd),
        _BalanceCard(
          balance: dashboard.balance?.balance,
          currency: dashboard.balance?.currency ?? AppConstants.defaultCurrency,
          hidden: _balanceHidden,
          onToggle: () => setState(() => _balanceHidden = !_balanceHidden),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        _QuickActions(onSelectTab: widget.onSelectTab),
        const SizedBox(height: AppConstants.spacingLg),
        _RecentHeader(onSeeAll: () => widget.onSelectTab(3)),
        const SizedBox(height: AppConstants.spacingSm),
        _RecentList(transactions: dashboard.recentTransactions),
      ],
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

class _Greeting extends StatelessWidget {
  const _Greeting({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour 👋',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          Formatters.phoneSenegal(phone),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.currency,
    required this.hidden,
    required this.onToggle,
  });

  final double? balance;
  final String currency;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final display = balance == null
        ? '— —'
        : (hidden ? '••••••' : Formatters.xof(balance!, symbol: ''));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(color: Colors.white70),
              ),
              IconButton(
                onPressed: onToggle,
                tooltip: hidden ? 'Afficher le solde' : 'Masquer le solde',
                icon: Icon(
                  hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  currency,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onSelectTab});
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          label: 'Transférer',
          icon: Icons.send_rounded,
          onTap: () => onSelectTab(1),
        ),
        _ActionButton(
          label: 'Payer',
          icon: Icons.receipt_long_rounded,
          onTap: () => onSelectTab(2),
        ),
        _ActionButton(
          label: 'Historique',
          icon: Icons.history_rounded,
          onTap: () => onSelectTab(3),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  const _RecentHeader({required this.onSeeAll});
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transactions récentes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('Voir tout')),
      ],
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.transactions});
  final List<WalletTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.inbox_rounded, color: AppColors.textSecondary),
            SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Text(
                'Aucune transaction pour le moment.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            TransactionTile(transaction: transactions[i]),
          ],
        ],
      ),
    );
  }
}

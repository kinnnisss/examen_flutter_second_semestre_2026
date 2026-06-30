import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/facture.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bills_provider.dart';
import 'bills_history_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final code = context.read<AuthProvider>().walletCode;
    if (code != null && code.isNotEmpty) {
      await context.read<BillsProvider>().refresh(code);
    }
  }

  void _onToggle(BillsProvider bills, Facture facture) {
    final error = bills.toggleSelection(facture);
    if (error != null) {
      AppSnackBar.info(context, error);
    }
  }

  void _payBlocked() {
    AppSnackBar.info(
      context,
      'Le paiement de factures n\'est pas encore exposé par BadWallet API. '
      'Le routage backend doit être confirmé.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bills = context.watch<BillsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          IconButton(
            tooltip: 'Historique des factures',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BillsHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Summary(bills: bills),
            _FilterBar(bills: bills),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: _buildBody(bills),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bills.hasSelection
          ? _SelectionBar(bills: bills, onPay: _payBlocked)
          : null,
    );
  }

  Widget _buildBody(BillsProvider bills) {
    if (bills.isLoading && !bills.hasData) {
      return const AppLoader(message: 'Chargement des factures...');
    }

    if (bills.error != null && !bills.hasData) {
      return _scrollable(
        AppErrorState(message: bills.error!, onRetry: _refresh),
      );
    }

    final factures = bills.factures;
    if (factures.isEmpty) {
      return _scrollable(
        const EmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'Aucune facture impayée',
          message: 'Vous êtes à jour. Rien à payer pour le moment.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingMd,
        AppConstants.spacingSm,
        AppConstants.spacingMd,
        AppConstants.spacingXl,
      ),
      itemCount: factures.length,
      itemBuilder: (_, i) => _FactureCard(
        facture: factures[i],
        selected: bills.isSelected(factures[i].reference),
        onToggle: () => _onToggle(bills, factures[i]),
        onPay: _payBlocked,
      ),
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

class _Summary extends StatelessWidget {
  const _Summary({required this.bills});
  final BillsProvider bills;

  @override
  Widget build(BuildContext context) {
    final factures = bills.factures;
    final total = factures.fold<double>(0, (sum, f) => sum + f.amount);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Factures impayées',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '${factures.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Total dû', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                Formatters.xof(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.bills});
  final BillsProvider bills;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      child: Row(
        children: [
          _chip(context, 'Toutes', null),
          const SizedBox(width: AppConstants.spacingSm),
          _chip(context, 'ISM', BillService.ism),
          const SizedBox(width: AppConstants.spacingSm),
          _chip(context, 'WOYAFAL', BillService.woyafal),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, BillService? service) {
    final selected = bills.filter == service;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => bills.setFilter(service),
    );
  }
}

class _FactureCard extends StatelessWidget {
  const _FactureCard({
    required this.facture,
    required this.selected,
    required this.onToggle,
    required this.onPay,
  });

  final Facture facture;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: selected,
            onChanged: (_) => onToggle(),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    facture.serviceName.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  Formatters.xof(facture.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line('Référence', facture.reference),
                  if (facture.billingMonth != null)
                    _line('Mois', Formatters.monthYear(facture.billingMonth!)),
                  if (facture.dueDate != null)
                    _line('Échéance', Formatters.date(facture.dueDate!)),
                  _line('Statut', facture.status.label),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingMd,
              0,
              AppConstants.spacingMd,
              AppConstants.spacingSm,
            ),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: onPay,
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Payer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.bills, required this.onPay});
  final BillsProvider bills;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bills.selectedCount} sélectionnée(s)'
                    '${bills.selectedService != null ? ' · ${bills.selectedService!.label}' : ''}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    Formatters.xof(bills.selectedTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: bills.clearSelection,
              child: const Text('Vider'),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: onPay,
              child: const Text('Payer'),
            ),
          ],
        ),
      ),
    );
  }
}

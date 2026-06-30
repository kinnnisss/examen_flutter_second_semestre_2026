import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/wallet_transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import 'transaction_tile.dart';

/// Onglet "Historique" : liste complète des transactions, avec filtres.
///
/// Données réelles via [HistoryProvider] (GET /api/wallets/{phone}/transactions).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            tooltip: 'Filtrer',
            onPressed: () => _openFilters(context, history),
            icon: Badge(
              isLabelVisible: history.hasActiveFilters,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (history.hasActiveFilters)
              _ActiveFiltersBar(history: history),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _refresh,
                child: _buildBody(history),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HistoryProvider history) {
    if (history.isLoading && !history.hasData) {
      return const AppLoader(message: 'Chargement de l\'historique...');
    }

    if (history.error != null && !history.hasData) {
      return _scrollable(
        AppErrorState(message: history.error!, onRetry: _refresh),
      );
    }

    final transactions = history.transactions;
    if (transactions.isEmpty) {
      return _scrollable(
        EmptyState(
          icon: Icons.history_rounded,
          title: history.hasActiveFilters
              ? 'Aucun résultat'
              : 'Aucune transaction',
          message: history.hasActiveFilters
              ? 'Aucune transaction ne correspond aux filtres.'
              : 'Vos opérations apparaîtront ici.',
          action: history.hasActiveFilters
              ? TextButton(
                  onPressed: history.resetFilters,
                  child: const Text('Réinitialiser les filtres'),
                )
              : null,
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

  void _openFilters(BuildContext context, HistoryProvider history) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) =>
          ChangeNotifierProvider<HistoryProvider>.value(
            value: history,
            child: const _FilterSheet(),
          ),
    );
  }
}

/// Bandeau résumant les filtres actifs avec une action de réinitialisation.
class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar({required this.history});
  final HistoryProvider history;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (history.typeFilter != null) history.typeFilter!.label,
      if (history.startDate != null)
        'Du ${Formatters.date(history.startDate!)}',
      if (history.endDate != null) 'Au ${Formatters.date(history.endDate!)}',
    ];

    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: chips
                  .map(
                    (c) => Chip(
                      label: Text(c, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
          ),
          TextButton(
            onPressed: history.resetFilters,
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}

/// Feuille de filtres : type de transaction + plage de dates.
class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    ValueChanged<DateTime?> onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spacingMd,
        right: AppConstants.spacingMd,
        top: AppConstants.spacingSm,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppConstants.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer les transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Text(
            'Type',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: 8,
            children: [
              _typeChip(history, null, 'Tous'),
              _typeChip(history, TransactionType.deposit, 'Dépôt'),
              _typeChip(history, TransactionType.withdrawal, 'Retrait'),
              _typeChip(history, TransactionType.transfer, 'Transfert'),
              _typeChip(history, TransactionType.billPayment, 'Facture'),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Date de début',
                  value: history.startDate,
                  onTap: () => _pickDate(
                    context,
                    history.startDate,
                    history.setStartDate,
                  ),
                  onClear: () => history.setStartDate(null),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _DateField(
                  label: 'Date de fin',
                  value: history.endDate,
                  onTap: () => _pickDate(
                    context,
                    history.endDate,
                    history.setEndDate,
                  ),
                  onClear: () => history.setEndDate(null),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: history.resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChip(
    HistoryProvider history,
    TransactionType? type,
    String label,
  ) {
    final selected = history.typeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => history.setTypeFilter(type),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          value != null ? Formatters.date(value!) : '—',
          style: TextStyle(
            color: value != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

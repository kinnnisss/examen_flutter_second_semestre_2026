import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/transfers_provider.dart';
import 'transfer_success_screen.dart';

class ConfirmTransferScreen extends StatelessWidget {
  const ConfirmTransferScreen({
    super.key,
    required this.senderPhone,
    required this.receiverPhone,
    required this.amount,
  });

  final String senderPhone;
  final String receiverPhone;
  final int amount;

  Future<void> _confirm(BuildContext context) async {
    final transfers = context.read<TransfersProvider>();
    final dashboard = context.read<DashboardProvider>();
    final history = context.read<HistoryProvider>();
    final phone = context.read<AuthProvider>().phoneNumber;
    final navigator = Navigator.of(context);

    final success = await transfers.transfer(
      senderPhone: senderPhone,
      receiverPhone: receiverPhone,
      amount: amount,
    );

    if (!context.mounted) return;

    if (!success) {
      AppSnackBar.error(
        context,
        transfers.error ?? 'Le transfert a échoué. Réessayez.',
      );
      return;
    }

    if (phone != null) {
      await dashboard.refresh(phone);
      await history.refresh(phone);
    }

    final result = transfers.lastResult;
    transfers.reset();

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => TransferSuccessScreen(
          receiverPhone: receiverPhone,
          amount: amount,
          newBalance: result?.senderNewBalance,
          currency: result?.currency ?? AppConstants.defaultCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TransfersProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer le transfert')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingMd),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Vous envoyez',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Text(
                      Formatters.xof(amount),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),
              Card(
                child: Column(
                  children: [
                    _Row(
                      label: 'Destinataire',
                      value: Formatters.phoneSenegal(receiverPhone),
                    ),
                    const Divider(height: 1),
                    _Row(
                      label: 'Expéditeur',
                      value: Formatters.phoneSenegal(senderPhone),
                    ),
                    const Divider(height: 1),
                    const _Row(label: 'Frais', value: 'Aucun (gratuit)'),
                    const Divider(height: 1),
                    _Row(
                      label: 'Montant total',
                      value: Formatters.xof(amount),
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Vérifiez les informations : un transfert est immédiat et '
                'définitif.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              PrimaryButton(
                label: 'Confirmer et envoyer',
                icon: Icons.lock_rounded,
                isLoading: isLoading,
                onPressed: () => _confirm(context),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              fontSize: emphasize ? 16 : 14,
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

class TransferSuccessScreen extends StatelessWidget {
  const TransferSuccessScreen({
    super.key,
    required this.receiverPhone,
    required this.amount,
    required this.currency,
    this.newBalance,
  });

  final String receiverPhone;
  final int amount;
  final String currency;
  final double? newBalance;

  void _close(BuildContext context, String destination) {
    Navigator.of(context).pop(destination);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close(context, 'home');
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  height: 96,
                  width: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Transfert réussi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                Text(
                  '${Formatters.xof(amount)} envoyés à\n'
                  '${Formatters.phoneSenegal(receiverPhone)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (newBalance != null) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingLg,
                      vertical: AppConstants.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusPill,
                      ),
                    ),
                    child: Text(
                      'Nouveau solde : '
                      '${Formatters.xof(newBalance!, symbol: currency)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _close(context, 'history'),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Voir l\'historique'),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(54),
                  ),
                  onPressed: () => _close(context, 'home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

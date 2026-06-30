import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final direction = transaction.direction;
    final color = switch (direction) {
      TransactionDirection.credit => AppColors.amountIn,
      TransactionDirection.debit => AppColors.amountOut,
      TransactionDirection.neutral => AppColors.textPrimary,
    };
    final sign = switch (direction) {
      TransactionDirection.credit => '+ ',
      TransactionDirection.debit => '- ',
      TransactionDirection.neutral => '',
    };

    final subtitle = transaction.description?.isNotEmpty == true
        ? transaction.description!
        : (transaction.createdAt != null
              ? Formatters.dateTime(transaction.createdAt!)
              : '');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(_iconFor(transaction), color: color, size: 20),
      ),
      title: Text(
        transaction.displayLabel,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign${Formatters.xof(transaction.amount, symbol: '')}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          if (transaction.fee > 0)
            Text(
              'frais ${Formatters.xof(transaction.fee, symbol: '')}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(WalletTransaction t) {
    switch (t.type) {
      case TransactionType.deposit:
        return Icons.south_west_rounded;
      case TransactionType.withdrawal:
        return Icons.north_east_rounded;
      case TransactionType.transfer:
        return switch (t.direction) {
          TransactionDirection.credit => Icons.south_west_rounded,
          TransactionDirection.debit => Icons.north_east_rounded,
          TransactionDirection.neutral => Icons.swap_horiz_rounded,
        };
      case TransactionType.billPayment:
        return Icons.receipt_long_rounded;
      case TransactionType.unknown:
        return Icons.receipt_rounded;
    }
  }
}

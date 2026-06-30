import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/wallet_transaction.dart';


class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;
    final color = isCredit ? AppColors.amountIn : AppColors.amountOut;
    final sign = isCredit ? '+' : '-';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(_iconFor(transaction.type), color: color, size: 20),
      ),
      title: Text(
        transaction.type.label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction.description?.isNotEmpty == true
            ? transaction.description!
            : (transaction.createdAt != null
                  ? Formatters.dateTime(transaction.createdAt!)
                  : ''),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign ${Formatters.xof(transaction.amount, symbol: '')}',
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

  IconData _iconFor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return Icons.south_west_rounded;
      case TransactionType.withdrawal:
        return Icons.north_east_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionType.billPayment:
        return Icons.receipt_long_rounded;
      case TransactionType.unknown:
        return Icons.receipt_rounded;
    }
  }
}

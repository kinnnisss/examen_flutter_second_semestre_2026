import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'confirm_transfer_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _validateReceiver(String? value, String senderPhone) {
    final base = Validators.phone(value);
    if (base != null) return base;

    final normalized = Formatters.toApiPhone(value ?? '');
    if (normalized != null && normalized == senderPhone) {
      return 'Le destinataire doit être différent de l\'expéditeur.';
    }
    return null;
  }

  String? _validateAmount(String? value, double? balance) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Le montant est obligatoire.';

    final amount = int.tryParse(raw);
    if (amount == null) return 'Le montant doit être un nombre entier.';
    if (amount <= 0) return 'Le montant doit être strictement positif.';
    if (balance != null && amount > balance) {
      return 'Montant supérieur au solde disponible.';
    }
    return null;
  }

  Future<void> _continue(String senderPhone) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final receiver = Formatters.toApiPhone(_receiverController.text)!;
    final amount = int.parse(_amountController.text.trim());

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ConfirmTransferScreen(
          senderPhone: senderPhone,
          receiverPhone: receiver,
          amount: amount,
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'home' || result == 'history') {
      _formKey.currentState!.reset();
      _receiverController.clear();
      _amountController.clear();
      widget.onSelectTab?.call(result == 'history' ? 3 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderPhone = context.watch<AuthProvider>().phoneNumber ?? '';
    final balance = context.watch<DashboardProvider>().balance;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfert')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SenderCard(
                  phone: senderPhone,
                  balance: balance?.balance,
                  currency: balance?.currency ?? AppConstants.defaultCurrency,
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Destinataire',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                TextFormField(
                  controller: _receiverController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '+221 77 000 00 02',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => _validateReceiver(v, senderPhone),
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'Montant',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'FCFA',
                  ),
                  validator: (v) => _validateAmount(v, balance?.balance),
                ),
                const SizedBox(height: AppConstants.spacingXl),
                PrimaryButton(
                  label: 'Continuer',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: senderPhone.isEmpty
                      ? null
                      : () => _continue(senderPhone),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SenderCard extends StatelessWidget {
  const _SenderCard({
    required this.phone,
    required this.balance,
    required this.currency,
  });

  final String phone;
  final double? balance;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_circle_rounded, color: AppColors.primary),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Depuis mon wallet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  Formatters.phoneSenegal(phone),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Solde',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                balance == null
                    ? '—'
                    : Formatters.xof(balance!, symbol: currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

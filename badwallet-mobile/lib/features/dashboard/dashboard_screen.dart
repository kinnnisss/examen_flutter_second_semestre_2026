import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_screen.dart';
import '../bills/bills_screen.dart';
import '../history/history_screen.dart';
import '../transfers/transfer_screen.dart';

/// Tableau de bord — point d'entrée principal après identification.
///
/// Pour ce lot, il sert aussi de coquille de navigation temporaire vers les
/// futures pages (Auth, Transfer, Bills, History) et affiche l'URL de l'API
/// actuellement configurée, utile pour vérifier la cible (émulateur / IP).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Connexion',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => _go(context, const AuthScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          _BalanceCard(),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            'Services',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _ActionsGrid(),
          const SizedBox(height: AppConstants.spacingLg),
          _ApiInfoCard(),
        ],
      ),
    );
  }

  static void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Solde disponible',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '— —',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'FCFA',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Text(
            'Connectez-vous pour afficher votre solde réel.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = <_ActionItem>[
      _ActionItem(
        'Transfert',
        Icons.send_rounded,
        () => _open(context, const TransferScreen()),
      ),
      _ActionItem(
        'Factures',
        Icons.receipt_long_rounded,
        () => _open(context, const BillsScreen()),
      ),
      _ActionItem(
        'Historique',
        Icons.history_rounded,
        () => _open(context, const HistoryScreen()),
      ),
      _ActionItem(
        'Connexion',
        Icons.account_balance_wallet_rounded,
        () => _open(context, const AuthScreen()),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.spacingMd,
      crossAxisSpacing: AppConstants.spacingSm,
      childAspectRatio: 0.8,
      children: actions
          .map(
            (a) => InkWell(
              onTap: a.onTap,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: Column(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMd,
                      ),
                    ),
                    child: Icon(a.icon, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _ActionItem {
  _ActionItem(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _ApiInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            const Icon(Icons.cloud_outlined, color: AppColors.textSecondary),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API configurée',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ApiConfig.baseUrl,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

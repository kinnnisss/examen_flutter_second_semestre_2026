import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/secure_storage_service.dart';
import 'features/splash/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/history_provider.dart';
import 'providers/transfers_provider.dart';
import 'services/wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR');

  runApp(const BadWalletApp());
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();
    final apiClient = ApiClient();
    final walletService = WalletService(apiClient);

    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<SecureStorageService>.value(value: storage),
        Provider<WalletService>.value(value: walletService),

        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            storage: storage,
            walletService: walletService,
          ),
        ),

        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(walletService),
        ),

        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => HistoryProvider(walletService),
        ),

        ChangeNotifierProvider<TransfersProvider>(
          create: (_) => TransfersProvider(walletService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}

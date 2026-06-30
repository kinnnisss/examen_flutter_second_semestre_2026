import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/secure_storage_service.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'providers/session_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les données de localisation FR pour intl (dates, mois).
  await initializeDateFormatting('fr_FR');

  runApp(const BadWalletApp());
}

class BadWalletApp extends StatelessWidget {
  const BadWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Services partagés (singletons applicatifs) injectés via Provider.
    final storage = SecureStorageService();

    return MultiProvider(
      providers: [
        // Client HTTP unique partagé par tous les services métier.
        Provider<ApiClient>(create: (_) => ApiClient()),

        // Service de stockage sécurisé.
        Provider<SecureStorageService>.value(value: storage),

        // État de session (numéro de wallet courant), chargé au démarrage.
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(storage)..load(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const DashboardScreen(),
      ),
    );
  }
}

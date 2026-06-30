# BadWallet Mobile

Application mobile Flutter **Consumer** pour BadWallet (style Wave / Orange Money / PayPal).
Elle consomme l'API Spring Boot **BadWallet** (port `8080`)

## Architecture (feature-first)

```
lib/
├── core/
│   ├── config/        api_config.dart (URL API centralisée)
│   ├── constants/     couleurs, endpoints, constantes
│   ├── network/       ApiClient (Dio), ApiException, mapper d'erreurs
│   ├── theme/         thème Material 3 + Poppins
│   ├── utils/         formatage XOF / téléphone, stockage sécurisé
│   └── widgets/       AppLoader, AppErrorState, EmptyState, PrimaryButton, AppSnackBar
├── features/
│   ├── auth/          Connexion (placeholder)
│   ├── dashboard/     Tableau de bord + navigation temporaire
│   ├── transfers/     Transfert (placeholder)
│   ├── bills/         Factures (placeholder)
│   └── history/       Historique (placeholder)
├── models/            Wallet, BalanceResponse, WalletTransaction, PageResponse<T>
├── providers/         SessionProvider (Provider)
└── main.dart          Provider + thème + navigation
```

## Configuration de l'URL API

L'URL est définie **uniquement** dans [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart).

| Cible | URL |
|-------|-----|
| Émulateur Android (par défaut) | `http://10.0.2.2:8080` |
| Simulateur iOS | `http://127.0.0.1:8080` |
| Téléphone physique | `http://<IP_LOCALE_DU_PC>:8080` |

### Émulateur Android

Rien à faire : la valeur par défaut `http://10.0.2.2:8080` pointe vers le PC hôte.

```bash
flutter run
```

### Téléphone physique

Surchargez l'URL au lancement (sans recompiler manuellement le code) :

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

> Remplacez `192.168.1.10` par l'IP locale de votre PC (`ipconfig`). Le téléphone
> et le PC doivent être sur le même réseau Wi-Fi, et le port `8080` accessible.

Alternative : modifier la constante `_defaultBaseUrl` dans `api_config.dart`.

## Commandes

```bash
flutter pub get        # dépendances
flutter analyze        # analyse statique
flutter test           # tests unitaires
flutter run            # lancer l'app
```

## Endpoints BadWallet consommés

- `GET  /api/wallets/{phoneNumber}` — wallet
- `GET  /api/wallets/{phoneNumber}/balance` — solde
- `GET  /api/wallets/{phoneNumber}/transactions` — historique
- `GET  /api/wallets?page=&size=` — liste paginée (`Page<T>`)
- `POST /api/wallets/transfer`, `/withdraw`, `/{id}/deposit`
- `GET  /api/external/factures/{walletCode}/current`

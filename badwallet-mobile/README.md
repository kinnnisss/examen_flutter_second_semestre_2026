# BadWallet Mobile

Application mobile **Flutter Consumer** pour BadWallet (style Wave / Orange Money / PayPal).
Elle consomme l'API Spring Boot **BadWallet** (port `8080`)

## Présentation

BadWallet Mobile permet à un client de :

- se connecter avec son numéro de téléphone (onboarding simulé, sans JWT) ;
- consulter son solde réel et ses dernières transactions ;
- effectuer un transfert d'argent vers un autre wallet ;
- consulter l'historique complet avec filtres ;
- consulter ses factures impayées (ISM / WOYAFAL) et préparer leur paiement.

## Technologies

- Flutter / Dart
- Dio (client HTTP)
- Provider (gestion d'état)
- intl (formatage XOF / dates)
- google_fonts (Poppins, Material 3)
- flutter_secure_storage (numéro de wallet courant)
- flutter_launcher_icons (configuration prête)

## Architecture (feature-first)

```
lib/
├── core/
│   ├── config/        api_config.dart (URL API centralisée)
│   ├── constants/     couleurs, endpoints, constantes
│   ├── network/       ApiClient (Dio), ApiException, mapper d'erreurs FR
│   ├── theme/         thème Material 3 + Poppins
│   ├── utils/         formatage XOF / téléphone, validators, secure storage
│   └── widgets/       AppLoader, AppErrorState, EmptyState, PrimaryButton, AppSnackBar
├── features/
│   ├── splash/        écran de démarrage + routage de session
│   ├── auth/          onboarding / login simulé
│   ├── dashboard/     solde, actions rapides, transactions récentes
│   ├── transfers/     transfert + confirmation + succès
│   ├── bills/         factures + historique des paiements
│   ├── history/       historique complet + filtres
│   ├── profile/       profil + déconnexion
│   └── home/          HomeShell (BottomNavigationBar)
├── models/            Wallet, BalanceResponse, WalletTransaction, PageResponse,
│                      Facture, TransferResult, FacturePaymentResult
├── providers/         Auth, Dashboard, Transfers, History, Bills
├── services/          WalletService, FactureService (appels API centralisés)
└── main.dart          Provider + thème + navigation
```

## Prérequis

- Flutter SDK (Dart `^3.11.5`)
- Un émulateur Android **ou** un téléphone physique
- Le backend BadWallet API démarré sur le port `8080`
  (et le payment-service sur `8081` pour les factures)

## Installation

```bash
cd badwallet-mobile
flutter pub get
flutter run
```

## Configuration de l'API

L'URL est définie **uniquement** dans `lib/core/config/api_config.dart`.

| Cible | URL |
|-------|-----|
| Émulateur Android (par défaut) | `http://10.0.2.2:8080` |
| Téléphone physique | `http://<IP_LOCALE_DU_PC>:8080` |

### Émulateur Android

Rien à configurer : `10.0.2.2` pointe vers le PC hôte.

```bash
flutter run
```

### Téléphone physique

Surcharger l'URL au lancement, sans modifier le code :

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Remplacer `192.168.1.10` par l'IP locale du PC (`ipconfig`). Le téléphone et le PC
doivent être sur le même réseau Wi-Fi, et le port `8080` accessible.
Pour un APK, passer le même `--dart-define` lors du `flutter build apk`.

> Le trafic HTTP en clair est autorisé (`usesCleartextTraffic`) car l'API locale
> est servie en `http://` et non `https://`.

## Lancer le backend

Dans le projet backend (lecture seule, non modifié) :

```
examen-design-pattern/badwallet-api      -> port 8080 (BadWallet API)
examen-design-pattern/payment-service    -> port 8081 (factures)
```

Démarrer d'abord PostgreSQL, puis chaque service Spring Boot.

## Parcours de démonstration

1. **Splash** BadWallet → lecture du stockage sécurisé.
2. **Login** : saisir un numéro d'un wallet existant (ex. `+221779998877` ou `+221770000003`).
3. **Dashboard** : solde réel, bouton œil (masquer/afficher), pull-to-refresh,
   actions rapides, 5 dernières transactions, « Voir tout ».
4. **Transfert** : destinataire + montant, validations, confirmation, succès,
   rafraîchissement automatique du solde et de l'historique.
5. **Historique** : liste complète, filtres (type, dates), couleurs crédit/débit.
6. **Factures** : en-tête (nb impayées + total), filtres Toutes/ISM/WOYAFAL,
   sélection multiple mono-fournisseur, total dynamique.
7. **Profil** : numéro du client, déconnexion avec confirmation.

## Fonctionnalités

- Onboarding simulé + stockage sécurisé du numéro
- Dashboard avec solde réel et masquage
- Transfert avec validations et confirmation
- Historique filtrable avec code couleur fiable
- Consultation des factures impayées avec filtres et sélection
- Messages d'erreur en français (réseau, timeout, 400, 404, 500)

## Génération de l'APK

```bash
flutter build apk --release
```

APK généré ici :

```
build/app/outputs/flutter-apk/app-release.apk
```

Pour cibler un téléphone physique avec une IP précise :

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## Limites connues (liées au backend / environnement)

- **Paiement de factures** : BadWallet API n'expose **aucune** route de paiement
  (`/pay`, `/pay-factures` inexistantes) et ne crée jamais de transaction
  `BILL_PAYMENT`. Le wallet n'est donc **pas débité** lors d'un paiement de
  facture, et l'« Historique des factures » reste vide. L'app affiche un message
  clair sans simuler de paiement. Dès qu'un proxy `POST /api/wallets/pay-factures`
  existera côté backend, le flux est prêt à être câblé.
- **Login simulé** : pas d'authentification JWT (identité = numéro vérifié via l'API).
- **Filtres factures par date** : appliqués côté client (l'endpoint ne pagine pas).
- **Icône de lancement** : la configuration `flutter_launcher_icons` est prête ;
  fournir `assets/icon/icon.png` (1024×1024) puis exécuter
  `flutter pub run flutter_launcher_icons` pour générer les icônes natives.
- **Release signé avec la clé debug** : suffisant pour une démo académique ;
  fournir un keystore pour une vraie distribution.

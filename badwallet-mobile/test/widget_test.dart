import 'package:flutter_test/flutter_test.dart';

import 'package:badwallet_mobile/core/utils/formatters.dart';
import 'package:badwallet_mobile/models/page_response.dart';
import 'package:badwallet_mobile/models/wallet.dart';
import 'package:badwallet_mobile/models/wallet_transaction.dart';

void main() {
  group('Formatters', () {
    test('xof formate un montant sans decimale avec separateur de milliers', () {
      // NumberFormat fr_FR utilise une espace insecable (U+202F/U+00A0) comme
      // separateur de milliers : on normalise toute espace en espace simple.
      final result = Formatters.xof(150000).replaceAll(RegExp(r'\s'), ' ');
      expect(result, '150 000 FCFA');
    });

    test('toApiPhone prefixe un local senegalais a 9 chiffres', () {
      expect(Formatters.toApiPhone('779998877'), '+221779998877');
    });

    test('toApiPhone conserve un numero deja international', () {
      expect(Formatters.toApiPhone('+221779998877'), '+221779998877');
    });
  });

  group('Models JSON', () {
    test('Wallet.fromJson mappe les champs reels du backend', () {
      final wallet = Wallet.fromJson(const {
        'id': 1,
        'phoneNumber': '+221779998877',
        'email': 'user@example.com',
        'code': 'WALLET01',
        'currency': 'XOF',
        'balance': 150000.0,
        'createdAt': '2026-06-30T12:00:00',
      });

      expect(wallet.id, 1);
      expect(wallet.code, 'WALLET01');
      expect(wallet.balance, 150000.0);
      expect(wallet.createdAt, isNotNull);
    });

    test('WalletTransaction.fromJson interprete le type enum', () {
      final tx = WalletTransaction.fromJson(const {
        'id': 10,
        'type': 'TRANSFER',
        'amount': 5000.0,
        'fee': 0.0,
        'currency': 'XOF',
        'description': 'Transfert',
        'createdAt': '2026-06-30T12:00:00',
      });

      expect(tx.type, TransactionType.transfer);
      expect(tx.type.label, 'Transfert');
    });

    test('PageResponse.fromJson mappe le contenu pagine', () {
      final page = PageResponse<Wallet>.fromJson(const {
        'content': [
          {
            'id': 1,
            'phoneNumber': '+221779998877',
            'email': 'a@b.com',
            'code': 'W1',
            'currency': 'XOF',
            'balance': 1000.0,
          },
        ],
        'totalElements': 1,
        'totalPages': 1,
        'number': 0,
        'size': 10,
        'first': true,
        'last': true,
      }, Wallet.fromJson);

      expect(page.content.length, 1);
      expect(page.totalElements, 1);
      expect(page.last, true);
    });
  });
}

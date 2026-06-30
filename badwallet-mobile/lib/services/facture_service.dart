import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/facture.dart';

class FactureService {
  FactureService(this._client);

  final ApiClient _client;

  String _encode(String value) => Uri.encodeComponent(value);

  Future<List<Facture>> getCurrentUnpaidFactures(
    String walletCode, {
    BillService? unite,
  }) async {
    final query = <String, dynamic>{};
    if (unite != null && unite != BillService.unknown) {
      query['unite'] = unite.apiValue;
    }

    final data = await _client.get(
      ApiEndpoints.currentFactures(_encode(walletCode)),
      queryParameters: query.isEmpty ? null : query,
    );

    final list = (data as List<dynamic>? ?? const []);
    return list
        .map((e) => Facture.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Facture>> getFacturesByPeriod(
    String walletCode, {
    required DateTime debut,
    required DateTime fin,
  }) async {
    final data = await _client.get(
      ApiEndpoints.facturesByPeriod(_encode(walletCode)),
      queryParameters: {
        'debut': _isoDate(debut),
        'fin': _isoDate(fin),
      },
    );

    final list = (data as List<dynamic>? ?? const []);
    return list
        .map((e) => Facture.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _isoDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}

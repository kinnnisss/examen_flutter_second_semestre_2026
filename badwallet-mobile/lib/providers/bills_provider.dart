import 'package:flutter/foundation.dart';

import '../core/utils/error_messages.dart';
import '../models/facture.dart';
import '../services/facture_service.dart';

class BillsProvider extends ChangeNotifier {
  BillsProvider(this._factureService);

  final FactureService _factureService;

  List<Facture> _all = const [];
  bool _isLoading = false;
  bool _isPaying = false;
  String? _error;
  String? _walletCode;

  BillService? _filter;
  final Set<String> _selected = <String>{};
  BillService? _selectedService;

  bool get isLoading => _isLoading;
  bool get isPaying => _isPaying;
  String? get error => _error;
  bool get hasData => _all.isNotEmpty;

  BillService? get filter => _filter;
  BillService? get selectedService => _selectedService;

  List<Facture> get factures {
    if (_filter == null) return List.unmodifiable(_all);
    return _all.where((f) => f.serviceName == _filter).toList();
  }

  int get selectedCount => _selected.length;
  bool get hasSelection => _selected.isNotEmpty;

  double get selectedTotal {
    double total = 0;
    for (final f in _all) {
      if (_selected.contains(f.reference)) total += f.amount;
    }
    return total;
  }

  List<Facture> get selectedFactures =>
      _all.where((f) => _selected.contains(f.reference)).toList();

  bool isSelected(String reference) => _selected.contains(reference);

  Future<void> refresh(String walletCode) async {
    _walletCode = walletCode;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final factures = await _factureService.getCurrentUnpaidFactures(
        walletCode,
      );
      _all = factures.where((f) => f.status != BillStatus.paid).toList();
      _pruneSelection();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorMessages.from(e);
      notifyListeners();
    }
  }

  Future<void> reload() async {
    if (_walletCode != null) await refresh(_walletCode!);
  }

  void setFilter(BillService? service) {
    _filter = service;
    notifyListeners();
  }

  String? toggleSelection(Facture facture) {
    if (_selected.contains(facture.reference)) {
      _selected.remove(facture.reference);
      if (_selected.isEmpty) _selectedService = null;
      notifyListeners();
      return null;
    }

    if (_selected.isNotEmpty && facture.serviceName != _selectedService) {
      return 'Vous ne pouvez sélectionner que des factures du même '
          'fournisseur pour un paiement groupé.';
    }

    _selected.add(facture.reference);
    _selectedService = facture.serviceName;
    notifyListeners();
    return null;
  }

  void clearSelection() {
    _selected.clear();
    _selectedService = null;
    notifyListeners();
  }

  void _pruneSelection() {
    final existing = _all.map((f) => f.reference).toSet();
    _selected.removeWhere((ref) => !existing.contains(ref));
    if (_selected.isEmpty) _selectedService = null;
  }

  void reset() {
    _all = const [];
    _error = null;
    _isLoading = false;
    _isPaying = false;
    _filter = null;
    _walletCode = null;
    clearSelection();
  }
}

import 'package:flutter/material.dart';
import '../models/chit_package_model.dart';
import '../models/provider_model.dart';
import '../services/admin_api_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminApiService _service = AdminApiService();

  // ── Packages state ────────────────────────────────────────────────────────
  List<ChitPackageModel> packages = [];
  bool packagesLoading = false;
  String? packagesError;

  // ── Providers state ───────────────────────────────────────────────────────
  List<ProviderModel> providers = [];
  bool providersLoading = false;
  String? providersError;

  // ── Analytics state ───────────────────────────────────────────────────────
  Map<String, dynamic>? analytics;
  bool analyticsLoading = false;
  String? analyticsError;

  // ── Packages ─────────────────────────────────────────────────────────────

  Future<void> loadPackages() async {
    packagesLoading = true;
    packagesError = null;
    notifyListeners();
    try {
      packages = await _service.getPackages();
    } catch (e) {
      packagesError = _parseError(e);
    } finally {
      packagesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPackage(Map<String, dynamic> body) async {
    try {
      final created = await _service.createPackage(body);
      packages = [created, ...packages];
      notifyListeners();
      return true;
    } catch (e) {
      packagesError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePackage(int id, Map<String, dynamic> body) async {
    try {
      final updated = await _service.updatePackage(id, body);
      final idx = packages.indexWhere((p) => p.id == id);
      if (idx >= 0) packages[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      packagesError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePackage(int id) async {
    try {
      await _service.deletePackage(id);
      packages.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      packagesError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ── Providers ─────────────────────────────────────────────────────────────

  Future<void> loadProviders() async {
    providersLoading = true;
    providersError = null;
    notifyListeners();
    try {
      providers = await _service.getProviders();
    } catch (e) {
      providersError = _parseError(e);
    } finally {
      providersLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProvider(Map<String, dynamic> body) async {
    try {
      final created = await _service.createProvider(body);
      providers = [created, ...providers];
      notifyListeners();
      return true;
    } catch (e) {
      providersError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProvider(int id, Map<String, dynamic> body) async {
    try {
      final updated = await _service.updateProvider(id, body);
      final idx = providers.indexWhere((p) => p.id == id);
      if (idx >= 0) providers[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      providersError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProvider(int id) async {
    try {
      await _service.deleteProvider(id);
      providers.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      providersError = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  Future<void> loadAnalytics() async {
    analyticsLoading = true;
    analyticsError = null;
    notifyListeners();
    try {
      analytics = await _service.getAnalytics();
    } catch (e) {
      analyticsError = _parseError(e);
    } finally {
      analyticsLoading = false;
      notifyListeners();
    }
  }

  String _parseError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}

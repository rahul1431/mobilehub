import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/payment_model.dart';
import '../services/member_api_service.dart';

class MemberProvider extends ChangeNotifier {
  final _svc = MemberApiService();

  // ── Dashboard ──────────────────────────────────────────────────────────────
  Map<String, dynamic>? dashData;
  bool dashLoading = false;
  String? dashError;

  // ── Payments ───────────────────────────────────────────────────────────────
  List<PaymentModel> payments = [];
  bool paymentsLoading = false;
  String? paymentsError;

  // ── My Groups ─────────────────────────────────────────────────────────────
  List<dynamic> myGroups = [];
  bool groupsLoading = false;
  String? groupsError;

  // ── Passbook ───────────────────────────────────────────────────────────────
  List<dynamic> ledger = [];
  Map<String, dynamic>? passbookSummary;
  bool passbookLoading = false;
  String? passbookError;

  // ── Dashboard ──────────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    dashLoading = true;
    dashError = null;
    notifyListeners();
    try {
      dashData = await _svc.getDashboard();
    } catch (e) {
      dashError = _msg(e);
    } finally {
      dashLoading = false;
      notifyListeners();
    }
  }

  // ── Payments ───────────────────────────────────────────────────────────────

  Future<void> loadPayments() async {
    paymentsLoading = true;
    paymentsError = null;
    notifyListeners();
    try {
      payments = await _svc.getPayments();
    } catch (e) {
      paymentsError = _msg(e);
    } finally {
      paymentsLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createOrder(int paymentId) async {
    try {
      return await _svc.createOrder(paymentId);
    } catch (e) {
      paymentsError = _msg(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final ok = await _svc.confirmPayment(
          orderId: orderId, paymentId: paymentId, signature: signature);
      if (ok) await loadPayments();
      return ok;
    } catch (e) {
      paymentsError = _msg(e);
      notifyListeners();
      return false;
    }
  }

  // ── My Groups ─────────────────────────────────────────────────────────────

  Future<void> loadMyGroups() async {
    groupsLoading = true;
    groupsError = null;
    // Serve cached data immediately while fetching
    _loadGroupsFromCache();
    notifyListeners();
    try {
      myGroups = await _svc.getMyGroups();
      _saveGroupsToCache(myGroups);
    } catch (e) {
      groupsError = _msg(e);
    } finally {
      groupsLoading = false;
      notifyListeners();
    }
  }

  void _loadGroupsFromCache() {
    try {
      final box  = Hive.box<String>('groups_cache');
      final json = box.get('my_groups');
      if (json != null) {
        final decoded = jsonDecode(json);
        if (decoded is List) myGroups = decoded;
      }
    } catch (_) {}
  }

  void _saveGroupsToCache(List<dynamic> data) {
    try {
      Hive.box<String>('groups_cache').put('my_groups', jsonEncode(data));
    } catch (_) {}
  }

  // ── Passbook ───────────────────────────────────────────────────────────────

  Future<void> loadPassbook() async {
    passbookLoading = true;
    passbookError = null;
    // Serve cached data immediately
    _loadPassbookFromCache();
    notifyListeners();
    try {
      final result = await _svc.getPassbook();
      ledger = result['data'] as List? ?? [];
      passbookSummary = result['summary'] as Map<String, dynamic>?;
      _savePassbookToCache(result);
    } catch (e) {
      passbookError = _msg(e);
    } finally {
      passbookLoading = false;
      notifyListeners();
    }
  }

  void _loadPassbookFromCache() {
    try {
      final box  = Hive.box<String>('passbook_cache');
      final json = box.get('passbook');
      if (json != null) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        ledger          = decoded['data'] as List? ?? [];
        passbookSummary = decoded['summary'] as Map<String, dynamic>?;
      }
    } catch (_) {}
  }

  void _savePassbookToCache(Map<String, dynamic> data) {
    try {
      Hive.box<String>('passbook_cache').put('passbook', jsonEncode(data));
    } catch (_) {}
  }

  Future<String?> requestPassbookPdf() async {
    try {
      return await _svc.requestPassbookPdf();
    } catch (_) {
      return null;
    }
  }

  String _msg(Object e) => e.toString().replaceAll('Exception: ', '');
}

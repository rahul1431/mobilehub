import 'package:flutter/material.dart';
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
    notifyListeners();
    try {
      myGroups = await _svc.getMyGroups();
    } catch (e) {
      groupsError = _msg(e);
    } finally {
      groupsLoading = false;
      notifyListeners();
    }
  }

  // ── Passbook ───────────────────────────────────────────────────────────────

  Future<void> loadPassbook() async {
    passbookLoading = true;
    passbookError = null;
    notifyListeners();
    try {
      final result = await _svc.getPassbook();
      ledger = result['data'] as List? ?? [];
      passbookSummary = result['summary'] as Map<String, dynamic>?;
    } catch (e) {
      passbookError = _msg(e);
    } finally {
      passbookLoading = false;
      notifyListeners();
    }
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

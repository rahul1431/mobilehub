import 'package:flutter/material.dart';
import '../models/chit_group_model.dart';
import '../models/cycle_model.dart';
import '../models/group_membership_model.dart';
import '../models/payment_model.dart';
import '../services/provider_api_service.dart';

class ProviderState extends ChangeNotifier {
  final ProviderApiService _svc = ProviderApiService();

  // ── Groups ────────────────────────────────────────────────────────────────
  List<ChitGroupModel> groups = [];
  bool groupsLoading = false;
  String? groupsError;

  // ── Dashboard stats ───────────────────────────────────────────────────────
  Map<String, dynamic>? dashStats;
  bool statsLoading = false;

  // ── Group detail ──────────────────────────────────────────────────────────
  List<GroupMemberModel> selectedGroupMembers = [];
  List<CycleModel> selectedGroupCycles = [];
  bool groupDetailLoading = false;
  String? groupDetailError;

  // ── Collections ───────────────────────────────────────────────────────────
  List<PaymentModel> pendingPayments = [];
  List<PaymentModel> recentPayments  = [];
  bool collectionsLoading = false;
  String? collectionsError;

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<void> loadGroups() async {
    groupsLoading = true;
    groupsError = null;
    notifyListeners();
    try {
      groups = await _svc.getGroups();
    } catch (e) {
      groupsError = _err(e);
    } finally {
      groupsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGroup(Map<String, dynamic> body) async {
    try {
      final g = await _svc.createGroup(body);
      groups = [g, ...groups];
      notifyListeners();
      return true;
    } catch (e) {
      groupsError = _err(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGroup(int id) async {
    try {
      await _svc.deleteGroup(id);
      groups.removeWhere((g) => g.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      groupsError = _err(e);
      notifyListeners();
      return false;
    }
  }

  // ── Dashboard stats ───────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    statsLoading = true;
    notifyListeners();
    try {
      dashStats = await _svc.getDashboardStats();
    } catch (_) {}
    statsLoading = false;
    notifyListeners();
  }

  // ── Group detail ──────────────────────────────────────────────────────────

  Future<void> loadGroupDetail(int groupId) async {
    groupDetailLoading = true;
    groupDetailError = null;
    selectedGroupMembers = [];
    selectedGroupCycles = [];
    notifyListeners();
    try {
      final members = await _svc.getGroupMembers(groupId);
      selectedGroupMembers = members;
    } catch (e) {
      groupDetailError = _err(e);
    } finally {
      groupDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember(int groupId, String phone) async {
    try {
      final m = await _svc.addMember(groupId, phone);
      selectedGroupMembers = [m, ...selectedGroupMembers];
      // Update memberships_count in local groups list
      final idx = groups.indexWhere((g) => g.id == groupId);
      if (idx >= 0) {
        final g = groups[idx];
        groups[idx] = ChitGroupModel(
          id: g.id, packageId: g.packageId, providerId: g.providerId,
          name: g.name, status: g.status, currentCycle: g.currentCycle,
          startDate: g.startDate, totalMembers: g.totalMembers,
          membershipsCount: (g.membershipsCount ?? 0) + 1,
          package: g.package, createdAt: g.createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      groupDetailError = _err(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMember(int groupId, int memberId) async {
    try {
      await _svc.removeMember(groupId, memberId);
      selectedGroupMembers.removeWhere((m) => m.memberId == memberId);
      notifyListeners();
      return true;
    } catch (e) {
      groupDetailError = _err(e);
      notifyListeners();
      return false;
    }
  }

  // ── Cycles ────────────────────────────────────────────────────────────────

  Future<bool> startCycle(int groupId, String method) async {
    try {
      final cycle = await _svc.startCycle(groupId, method);
      selectedGroupCycles = [cycle, ...selectedGroupCycles];
      // Update group status locally
      final idx = groups.indexWhere((g) => g.id == groupId);
      if (idx >= 0) {
        final g = groups[idx];
        groups[idx] = ChitGroupModel(
          id: g.id, packageId: g.packageId, providerId: g.providerId,
          name: g.name, status: 'active',
          currentCycle: cycle.cycleNumber,
          startDate: g.startDate, totalMembers: g.totalMembers,
          membershipsCount: g.membershipsCount,
          package: g.package, createdAt: g.createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      groupDetailError = _err(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> pickWinner(int cycleId, String method, {int? winnerId}) async {
    try {
      final updated = await _svc.pickWinner(cycleId, method, winnerId: winnerId);
      final idx = selectedGroupCycles.indexWhere((c) => c.id == cycleId);
      if (idx >= 0) selectedGroupCycles[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      groupDetailError = _err(e);
      notifyListeners();
      return false;
    }
  }

  // ── Collections ───────────────────────────────────────────────────────────

  Future<void> loadCollections() async {
    collectionsLoading = true;
    collectionsError = null;
    notifyListeners();
    try {
      final all = await _svc.getCollections();
      pendingPayments = all.where((p) => p.isPending).toList();
      recentPayments  = all.where((p) => p.isPaid).take(20).toList();
    } catch (e) {
      collectionsError = _err(e);
    } finally {
      collectionsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordPayment(int paymentId, String method) async {
    try {
      final updated = await _svc.recordPayment(paymentId, method);
      pendingPayments.removeWhere((p) => p.id == paymentId);
      recentPayments = [updated, ...recentPayments];
      notifyListeners();
      return true;
    } catch (e) {
      collectionsError = _err(e);
      notifyListeners();
      return false;
    }
  }

  String _err(Object e) => e.toString().replaceAll('Exception: ', '');
}

import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/chit_group_model.dart';
import '../models/cycle_model.dart';
import '../models/group_membership_model.dart';
import '../models/payment_model.dart';

class ProviderApiService {
  Dio get _dio => ApiClient.instance;

  // ── Groups ────────────────────────────────────────────────────────────────

  Future<List<ChitGroupModel>> getGroups() async {
    final res = await _dio.get('/provider/groups');
    final List data = res.data['data'] ?? [];
    return data.map((e) => ChitGroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChitGroupModel> createGroup(Map<String, dynamic> body) async {
    final res = await _dio.post('/provider/groups', data: body);
    return ChitGroupModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ChitGroupModel> getGroupDetail(int id) async {
    final res = await _dio.get('/provider/groups/$id');
    return ChitGroupModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteGroup(int id) async {
    await _dio.delete('/provider/groups/$id');
  }

  // ── Members ───────────────────────────────────────────────────────────────

  Future<List<GroupMemberModel>> getGroupMembers(int groupId) async {
    final res = await _dio.get('/provider/groups/$groupId');
    final List mems = res.data['data']['memberships'] ?? [];
    return mems.map((e) => GroupMemberModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GroupMemberModel> addMember(int groupId, String phone) async {
    final res = await _dio.post('/provider/groups/$groupId/members', data: {'phone': phone});
    return GroupMemberModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> removeMember(int groupId, int memberId) async {
    await _dio.delete('/provider/groups/$groupId/members/$memberId');
  }

  Future<List<dynamic>> getAllMembers({int page = 1}) async {
    final res = await _dio.get('/provider/members', queryParameters: {'page': page});
    return res.data['data']['data'] ?? res.data['data'] ?? [];
  }

  // ── Cycles ────────────────────────────────────────────────────────────────

  Future<CycleModel> startCycle(int groupId, String method) async {
    final res = await _dio.post('/provider/groups/$groupId/start-cycle', data: {'cycle_method': method});
    return CycleModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<CycleModel> pickWinner(int cycleId, String method, {int? winnerId}) async {
    final res = await _dio.post('/provider/cycles/$cycleId/pick-winner', data: {
      'method': method,
      if (winnerId != null) 'winner_id': winnerId,
    });
    return CycleModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<CycleModel> getCycle(int cycleId) async {
    final res = await _dio.get('/provider/cycles/$cycleId');
    return CycleModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── Collections ───────────────────────────────────────────────────────────

  Future<List<PaymentModel>> getCollections({int page = 1}) async {
    final res = await _dio.get('/provider/collections', queryParameters: {'page': page});
    final List data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaymentModel> recordPayment(int paymentId, String method) async {
    final res = await _dio.post('/provider/payments/record', data: {
      'payment_id': paymentId,
      'payment_method': method,
    });
    return PaymentModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── Dashboard stats ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    // Aggregate from groups list since no dedicated endpoint yet
    final groups = await getGroups();
    final active    = groups.where((g) => g.isActive).length;
    final forming   = groups.where((g) => g.isForming).length;
    final completed = groups.where((g) => g.isCompleted).length;
    int totalMembers = 0;
    for (final g in groups) {
      totalMembers += g.membershipsCount ?? 0;
    }
    return {
      'total_groups':   groups.length,
      'active_groups':  active,
      'forming_groups': forming,
      'completed_groups': completed,
      'total_members':  totalMembers,
      'groups':         groups,
    };
  }
}

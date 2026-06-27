import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/chit_package_model.dart';
import '../models/provider_model.dart';

class AdminApiService {
  Dio get _dio => ApiClient.instance;

  // ── Packages ─────────────────────────────────────────────────────────────

  Future<List<ChitPackageModel>> getPackages() async {
    final res = await _dio.get('/admin/packages');
    final List data = res.data['data'] ?? res.data;
    return data.map((e) => ChitPackageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChitPackageModel> createPackage(Map<String, dynamic> body) async {
    final res = await _dio.post('/admin/packages', data: body);
    return ChitPackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ChitPackageModel> updatePackage(int id, Map<String, dynamic> body) async {
    final res = await _dio.put('/admin/packages/$id', data: body);
    return ChitPackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePackage(int id) async {
    await _dio.delete('/admin/packages/$id');
  }

  // ── Providers ─────────────────────────────────────────────────────────────

  Future<List<ProviderModel>> getProviders() async {
    final res = await _dio.get('/admin/providers');
    final List data = res.data['data'] ?? res.data;
    return data.map((e) => ProviderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProviderModel> createProvider(Map<String, dynamic> body) async {
    final res = await _dio.post('/admin/providers', data: body);
    return ProviderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<ProviderModel> updateProvider(int id, Map<String, dynamic> body) async {
    final res = await _dio.put('/admin/providers/$id', data: body);
    return ProviderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProvider(int id) async {
    await _dio.delete('/admin/providers/$id');
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalytics() async {
    final res = await _dio.get('/admin/analytics');
    return Map<String, dynamic>.from(res.data['data'] ?? res.data);
  }
}

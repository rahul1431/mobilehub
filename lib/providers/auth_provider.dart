import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/profile_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  ProfileModel? _profile;
  String? _errorMessage;

  AuthState get state       => _state;
  ProfileModel? get profile => _profile;
  String? get error         => _errorMessage;
  bool get isAuthenticated  => _state == AuthState.authenticated;

  Future<void> checkAuthStatus() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      _state = AuthState.loading;
      notifyListeners();
      final response = await ApiClient.instance.get('/auth/me');
      _profile = ProfileModel.fromJson(response.data['data']);
      _state = AuthState.authenticated;
    } catch (_) {
      await ApiClient.clearToken();
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _errorMessage = null;
    try {
      await ApiClient.instance.post('/auth/send-otp', data: {'phone': phone});
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to send OTP. Try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _errorMessage = null;
    try {
      _state = AuthState.loading;
      notifyListeners();
      final response = await ApiClient.instance.post(
        '/auth/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );
      final token = response.data['data']['token'] as String;
      await ApiClient.saveToken(token);
      _profile = ProfileModel.fromJson(response.data['data']['user']);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Invalid OTP. Please try again.';
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {}
    await ApiClient.clearToken();
    _profile = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}

import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/payment_model.dart';

class MemberApiService {
  Dio get _dio => ApiClient.instance;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get('/member/dashboard');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<PaymentModel>> getPayments({int page = 1}) async {
    final res = await _dio.get('/member/payments', queryParameters: {'page': page});
    // Handles both paginated {data:{data:[...]}} and plain {data:[...]} shapes
    final raw = res.data['data'];
    final List list = raw is Map ? (raw['data'] ?? []) : (raw ?? []);
    return list.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> createOrder(int paymentId) async {
    final res = await _dio.post('/member/payments/create-order',
        data: {'payment_id': paymentId});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<bool> confirmPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final res = await _dio.post('/member/payments/confirm', data: {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
    });
    return res.data['success'] == true;
  }

  Future<Map<String, dynamic>> getPassbook() async {
    final res = await _dio.get('/member/passbook');
    return res.data as Map<String, dynamic>;
  }

  Future<String> requestPassbookPdf() async {
    final res = await _dio.get('/member/passbook/pdf');
    return res.data['message'] as String? ?? 'Your passbook PDF is being generated.';
  }

  Future<List<dynamic>> getMyGroups() async {
    final res = await _dio.get('/member/groups');
    final raw = res.data['data'];
    final List list = raw is Map ? (raw['data'] ?? []) : (raw ?? []);
    return list;
  }
}

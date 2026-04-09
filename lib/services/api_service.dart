import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://38.134.148.188/3/api';
  static const String webUrl = 'http://3.yoghub.io';

  Future<Map<String, dynamic>> fetchDashboardMetrics() async {
    // Mirror the logic from trade-tips.js to fetch prices and analytics
    final response = await http.get(Uri.parse('$baseUrl/analytics.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load analytics');
  }

  Future<List<dynamic>> fetchAlphaSignals() async {
    // In actual app, we would fetch from market_proxy or a specific signals endpoint
    final response = await http.get(Uri.parse('$baseUrl/market_proxy.php?endpoint=/api/v3/ticker/price'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }
}

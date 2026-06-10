import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/binance_models.dart';

class NewsService {
  static const _baseUrl = 'https://min-api.cryptocompare.com/data/v2/news/';

  Future<List<CryptoNews>> fetchNews({String? category}) async {
    try {
      var url = '$_baseUrl?lang=EN&sortOrder=popular';
      if (category != null && category.isNotEmpty) url += '&categories=$category';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = (data['Data'] as List?) ?? [];
      return items.map((e) => CryptoNews.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

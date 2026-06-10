import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/binance_models.dart';

class BinanceService {
  static const String _prodUrl = 'https://fapi.binance.com';
  static const String _testUrl = 'https://testnet.binancefuture.com';

  final String apiKey;
  final String apiSecret;
  final bool useTestnet;

  BinanceService({
    required this.apiKey,
    required this.apiSecret,
    this.useTestnet = true,
  });

  String get _baseUrl => useTestnet ? _testUrl : _prodUrl;

  String _sign(String data) {
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    return hmac.convert(utf8.encode(data)).toString();
  }

  Map<String, String> get _headers => {
        'X-MBX-APIKEY': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  String _buildSignedQuery(Map<String, String> params) {
    params['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    params['recvWindow'] = '5000';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$query&signature=${_sign(query)}';
  }

  Future<dynamic> _get(String path, [Map<String, String>? params]) async {
    final query = _buildSignedQuery(params ?? {});
    final uri = Uri.parse('$_baseUrl$path?$query');
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['msg'] ?? 'HTTP ${res.statusCode}');
    }
    return body;
  }

  Future<dynamic> _post(String path, Map<String, String> params) async {
    final query = _buildSignedQuery(params);
    final uri = Uri.parse('$_baseUrl$path');
    final res = await http.post(uri, headers: _headers, body: query).timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    if (res.statusCode != 200) {
      throw Exception(body['msg'] ?? 'HTTP ${res.statusCode}');
    }
    return body;
  }

  Future<BinanceBalance?> getUsdtBalance() async {
    final data = await _get('/fapi/v2/balance');
    for (final b in data as List) {
      if (b['asset'] == 'USDT') return BinanceBalance.fromJson(b);
    }
    return null;
  }

  Future<List<BinancePosition>> getOpenPositions() async {
    final data = await _get('/fapi/v2/positionRisk');
    return (data as List)
        .map((p) => BinancePosition.fromJson(p))
        .where((p) => p.isOpen)
        .toList();
  }

  Future<void> setLeverage(String symbol, int leverage) async {
    await _post('/fapi/v1/leverage', {
      'symbol': symbol,
      'leverage': leverage.toString(),
    });
  }

  Future<BinanceOrder> placeMarketOrder({
    required String symbol,
    required String side,
    required double quantity,
  }) async {
    final qty = _formatQuantity(symbol, quantity);
    final result = await _post('/fapi/v1/order', {
      'symbol': symbol,
      'side': side,
      'type': 'MARKET',
      'quantity': qty,
    });
    return BinanceOrder.fromJson(result);
  }

  Future<BinanceOrder> placeStopMarketOrder({
    required String symbol,
    required String side,
    required double quantity,
    required double stopPrice,
  }) async {
    final result = await _post('/fapi/v1/order', {
      'symbol': symbol,
      'side': side,
      'type': 'STOP_MARKET',
      'quantity': _formatQuantity(symbol, quantity),
      'stopPrice': _formatPrice(symbol, stopPrice),
      'closePosition': 'false',
    });
    return BinanceOrder.fromJson(result);
  }

  Future<BinanceOrder> placeTakeProfitOrder({
    required String symbol,
    required String side,
    required double quantity,
    required double stopPrice,
  }) async {
    final result = await _post('/fapi/v1/order', {
      'symbol': symbol,
      'side': side,
      'type': 'TAKE_PROFIT_MARKET',
      'quantity': _formatQuantity(symbol, quantity),
      'stopPrice': _formatPrice(symbol, stopPrice),
      'closePosition': 'false',
    });
    return BinanceOrder.fromJson(result);
  }

  Future<void> closePosition(String symbol, double positionAmt) async {
    final side = positionAmt > 0 ? 'SELL' : 'BUY';
    await placeMarketOrder(
      symbol: symbol,
      side: side,
      quantity: positionAmt.abs(),
    );
  }

  Future<double> getPrice(String symbol) async {
    final uri = Uri.parse('$_baseUrl/fapi/v1/ticker/price?symbol=$symbol');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    final body = json.decode(res.body);
    return double.tryParse(body['price']?.toString() ?? '0') ?? 0;
  }

  Future<List<List<double>>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 60,
  }) async {
    final uri = Uri.parse('$_baseUrl/fapi/v1/klines?symbol=$symbol&interval=$interval&limit=$limit');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Failed to fetch klines: ${res.statusCode}');
    final data = json.decode(res.body) as List;
    return data.map<List<double>>((k) => [
          double.tryParse(k[1].toString()) ?? 0, // open
          double.tryParse(k[2].toString()) ?? 0, // high
          double.tryParse(k[3].toString()) ?? 0, // low
          double.tryParse(k[4].toString()) ?? 0, // close
          double.tryParse(k[5].toString()) ?? 0, // volume
        ]).toList();
  }

  String _formatQuantity(String symbol, double qty) {
    final precision = _quantityPrecision(symbol);
    if (precision == 0) return qty.truncate().toString();
    final factor = _pow10(precision);
    final truncated = (qty * factor).truncate() / factor;
    return truncated.toStringAsFixed(precision);
  }

  String _formatPrice(String symbol, double price) {
    return price.toStringAsFixed(_pricePrecision(symbol));
  }

  int _quantityPrecision(String symbol) {
    const map = {
      'BTCUSDT': 3,
      'ETHUSDT': 3,
      'BNBUSDT': 2,
      'SOLUSDT': 0,
      'XRPUSDT': 0,
      'DOGEUSDT': 0,
      'ADAUSDT': 0,
      'LINKUSDT': 1,
    };
    return map[symbol] ?? 2;
  }

  int _pricePrecision(String symbol) {
    const map = {
      'BTCUSDT': 1,
      'ETHUSDT': 2,
      'BNBUSDT': 2,
      'SOLUSDT': 3,
      'XRPUSDT': 4,
      'DOGEUSDT': 5,
      'ADAUSDT': 4,
      'LINKUSDT': 3,
    };
    return map[symbol] ?? 2;
  }

  double _pow10(int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) result *= 10;
    return result;
  }
}

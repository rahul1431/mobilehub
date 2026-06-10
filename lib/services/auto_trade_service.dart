import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/binance_models.dart';
import 'binance_service.dart';

class AutoTradeService extends ChangeNotifier {
  TradeConfig _config = TradeConfig.defaults();
  BinanceService? _binance;
  Timer? _timer;
  bool _isRunning = false;
  List<BinancePosition> _positions = [];
  BinanceBalance? _balance;
  final List<TradeLog> _logs = [];
  String _status = 'Idle — configure API keys to begin';

  TradeConfig get config => _config;
  bool get isRunning => _isRunning;
  List<BinancePosition> get positions => List.unmodifiable(_positions);
  BinanceBalance? get balance => _balance;
  List<TradeLog> get logs => List.unmodifiable(_logs);
  String get status => _status;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('trade_config');
    if (saved != null) {
      try {
        _config = TradeConfig.fromJson(json.decode(saved));
        _binance = BinanceService(
          apiKey: _config.apiKey,
          apiSecret: _config.apiSecret,
          useTestnet: _config.useTestnet,
        );
      } catch (_) {}
    }
    notifyListeners();
  }

  void updateConfig(TradeConfig config) {
    _config = config;
    _binance = BinanceService(
      apiKey: config.apiKey,
      apiSecret: config.apiSecret,
      useTestnet: config.useTestnet,
    );
    notifyListeners();
  }

  void _addLog(String symbol, String action, String message, {bool isError = false}) {
    _logs.insert(0, TradeLog(
      timestamp: DateTime.now(),
      symbol: symbol,
      action: action,
      message: message,
      isError: isError,
    ));
    if (_logs.length > 150) _logs.removeRange(150, _logs.length);
    notifyListeners();
  }

  Future<void> start() async {
    if (_isRunning) return;
    if (_config.apiKey.isEmpty || _config.apiSecret.isEmpty) {
      _addLog('SYS', 'ERROR', 'API key and secret required', isError: true);
      _status = 'Error: API keys not configured';
      notifyListeners();
      return;
    }
    _binance = BinanceService(
      apiKey: _config.apiKey,
      apiSecret: _config.apiSecret,
      useTestnet: _config.useTestnet,
    );
    _isRunning = true;
    _status = 'Starting...';
    notifyListeners();

    final mode = _config.useTestnet ? 'Testnet' : 'Live';
    _addLog('SYS', 'START', 'Bot started • ${_config.leverage}x leverage • $mode');

    await _runCycle();
    // Scan every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => _runCycle());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _status = 'Stopped';
    _addLog('SYS', 'STOP', 'Auto trading stopped');
    notifyListeners();
  }

  Future<void> refreshData() async {
    final svc = _binance;
    if (svc == null) return;
    try {
      final results = await Future.wait([
        svc.getUsdtBalance(),
        svc.getOpenPositions(),
      ]);
      _balance = results[0] as BinanceBalance?;
      _positions = results[1] as List<BinancePosition>;
      notifyListeners();
    } catch (e) {
      _addLog('SYS', 'ERR', 'Refresh failed: $e', isError: true);
    }
  }

  Future<void> _runCycle() async {
    final svc = _binance;
    if (svc == null || !_isRunning) return;

    _status = 'Scanning markets...';
    notifyListeners();

    try {
      await refreshData();

      for (final symbol in _config.tradingPairs) {
        if (!_isRunning) break;
        await _processSymbol(svc, symbol);
        // Small delay between pair checks to respect rate limits
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (_isRunning) {
        _status = 'Active — next scan in 5m';
        notifyListeners();
      }
    } catch (e) {
      _status = 'Cycle error: $e';
      _addLog('SYS', 'ERR', e.toString(), isError: true);
      notifyListeners();
    }
  }

  Future<void> _processSymbol(BinanceService svc, String symbol) async {
    try {
      // Skip if already have open position for this symbol
      final hasPosition = _positions.any((p) => p.symbol == symbol && p.isOpen);
      if (hasPosition) return;

      final klines = await svc.getKlines(symbol, interval: '1h', limit: 55);
      if (klines.length < 30) return;

      final closes = klines.map((k) => k[3]).toList();
      final signal = _analyzeSignal(symbol, closes);

      if (signal.type == TradeSignalType.neutral) return;

      final bal = _balance;
      if (bal == null || bal.availableBalance < 5) {
        _addLog(symbol, 'SKIP', 'Insufficient balance (\$${bal?.availableBalance.toStringAsFixed(2) ?? '0'})');
        return;
      }

      final currentPrice = closes.last;
      // Margin = availableBalance × positionSize%
      final margin = bal.availableBalance * (_config.positionSizePct / 100);
      // Notional = margin × leverage
      final notional = margin * _config.leverage;
      final quantity = notional / currentPrice;

      if (quantity <= 0) return;

      final side = signal.type == TradeSignalType.buy ? 'BUY' : 'SELL';
      final closeSide = signal.type == TradeSignalType.buy ? 'SELL' : 'BUY';

      _addLog(
        symbol,
        side,
        '${signal.type == TradeSignalType.buy ? '▲ LONG' : '▼ SHORT'} | '
        'EMA9=${signal.ema9.toStringAsFixed(2)} EMA21=${signal.ema21.toStringAsFixed(2)} RSI=${signal.rsi.toStringAsFixed(1)}',
      );

      // Set leverage before placing order
      await svc.setLeverage(symbol, _config.leverage);

      // Place market entry order
      await svc.placeMarketOrder(symbol: symbol, side: side, quantity: quantity);

      // Calculate SL and TP prices
      final sl = signal.type == TradeSignalType.buy
          ? currentPrice * (1 - _config.stopLossPct / 100)
          : currentPrice * (1 + _config.stopLossPct / 100);
      final tp = signal.type == TradeSignalType.buy
          ? currentPrice * (1 + _config.takeProfitPct / 100)
          : currentPrice * (1 - _config.takeProfitPct / 100);

      // Place protective SL order
      await svc.placeStopMarketOrder(
        symbol: symbol,
        side: closeSide,
        quantity: quantity,
        stopPrice: sl,
      );

      // Place TP order
      await svc.placeTakeProfitOrder(
        symbol: symbol,
        side: closeSide,
        quantity: quantity,
        stopPrice: tp,
      );

      _addLog(
        symbol,
        'PLACED',
        'SL=\$${sl.toStringAsFixed(2)} TP=\$${tp.toStringAsFixed(2)} Qty=${quantity.toStringAsFixed(4)}',
      );

      await refreshData();
    } catch (e) {
      _addLog(symbol, 'ERR', e.toString(), isError: true);
    }
  }

  TradeSignal _analyzeSignal(String symbol, List<double> closes) {
    final ema9List = _calcEMA(closes, 9);
    final ema21List = _calcEMA(closes, 21);
    final rsi = _calcRSI(closes, 14);

    if (ema9List.length < 2 || ema21List.length < 2) {
      return TradeSignal(symbol: symbol, type: TradeSignalType.neutral, price: closes.last, ema9: 0, ema21: 0, rsi: rsi);
    }

    final ema9Now = ema9List.last;
    final ema21Now = ema21List.last;
    final ema9Prev = ema9List[ema9List.length - 2];
    final ema21Prev = ema21List[ema21List.length - 2];
    final price = closes.last;

    // Bullish crossover: EMA9 crosses above EMA21, RSI not overbought
    if (ema9Prev <= ema21Prev && ema9Now > ema21Now && rsi < 70 && rsi > 40) {
      return TradeSignal(symbol: symbol, type: TradeSignalType.buy, price: price, ema9: ema9Now, ema21: ema21Now, rsi: rsi);
    }

    // Bearish crossover: EMA9 crosses below EMA21, RSI not oversold
    if (ema9Prev >= ema21Prev && ema9Now < ema21Now && rsi > 30 && rsi < 60) {
      return TradeSignal(symbol: symbol, type: TradeSignalType.sell, price: price, ema9: ema9Now, ema21: ema21Now, rsi: rsi);
    }

    return TradeSignal(symbol: symbol, type: TradeSignalType.neutral, price: price, ema9: ema9Now, ema21: ema21Now, rsi: rsi);
  }

  List<double> _calcEMA(List<double> prices, int period) {
    if (prices.length < period) return [];
    final k = 2.0 / (period + 1);

    double sma = 0;
    for (int i = 0; i < period; i++) sma += prices[i];
    sma /= period;

    final result = <double>[sma];
    for (int i = period; i < prices.length; i++) {
      result.add(prices[i] * k + result.last * (1 - k));
    }
    return result;
  }

  double _calcRSI(List<double> closes, int period) {
    if (closes.length < period + 1) return 50;

    double gain = 0, loss = 0;
    for (int i = 1; i <= period; i++) {
      final diff = closes[i] - closes[i - 1];
      if (diff > 0) gain += diff;
      else loss -= diff;
    }
    double avgGain = gain / period;
    double avgLoss = loss / period;

    for (int i = period + 1; i < closes.length; i++) {
      final diff = closes[i] - closes[i - 1];
      avgGain = (avgGain * (period - 1) + (diff > 0 ? diff : 0)) / period;
      avgLoss = (avgLoss * (period - 1) + (diff < 0 ? -diff : 0)) / period;
    }

    if (avgLoss == 0) return 100;
    return 100 - (100 / (1 + avgGain / avgLoss));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

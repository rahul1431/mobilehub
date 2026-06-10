import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  List<TradeSignal> _marketSignals = [];
  bool _isLoadingSignals = false;

  TradeConfig get config => _config;
  bool get isRunning => _isRunning;
  List<BinancePosition> get positions => List.unmodifiable(_positions);
  BinanceBalance? get balance => _balance;
  List<TradeLog> get logs => List.unmodifiable(_logs);
  String get status => _status;
  List<TradeSignal> get marketSignals => List.unmodifiable(_marketSignals);
  bool get isLoadingSignals => _isLoadingSignals;

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
    _addLog('SYS', 'START',
        'Bot started • ${_config.leverage}x leverage • $mode • Min confidence: ${_config.confidenceThreshold}%');

    await _runCycle();
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

  // Public method to analyze market without placing orders (for Insights screen)
  Future<void> analyzeMarketSignals() async {
    if (_isLoadingSignals) return;
    _isLoadingSignals = true;
    notifyListeners();

    final pairs = _config.tradingPairs.isNotEmpty
        ? _config.tradingPairs
        : ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'XRPUSDT'];

    // Public klines endpoint — no auth needed, use prod URL
    final svc = BinanceService(apiKey: '', apiSecret: '', useTestnet: false);
    final signals = <TradeSignal>[];

    for (final symbol in pairs) {
      try {
        final klines = await svc.getKlines(symbol, interval: '1h', limit: 100);
        if (klines.length >= 50) {
          signals.add(_analyzeSignal(symbol, klines));
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _marketSignals = signals;
    _isLoadingSignals = false;
    notifyListeners();
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
      final hasPosition = _positions.any((p) => p.symbol == symbol && p.isOpen);
      if (hasPosition) return;

      final klines = await svc.getKlines(symbol, interval: '1h', limit: 100);
      if (klines.length < 50) return;

      final signal = _analyzeSignal(symbol, klines);

      if (signal.type == TradeSignalType.neutral) {
        _addLog(symbol, 'SCAN',
            'Confidence ${signal.confidence}% < threshold ${_config.confidenceThreshold}%');
        return;
      }

      final bal = _balance;
      if (bal == null || bal.availableBalance < 5) {
        _addLog(symbol, 'SKIP',
            'Insufficient balance (\$${bal?.availableBalance.toStringAsFixed(2) ?? '0'})');
        return;
      }

      final currentPrice = signal.price;
      final margin = bal.availableBalance * (_config.positionSizePct / 100);
      final notional = margin * _config.leverage;
      final quantity = notional / currentPrice;

      if (quantity <= 0) return;

      final side = signal.type == TradeSignalType.buy ? 'BUY' : 'SELL';
      final closeSide = signal.type == TradeSignalType.buy ? 'SELL' : 'BUY';

      _addLog(
        symbol,
        side,
        '${signal.type == TradeSignalType.buy ? '▲ LONG' : '▼ SHORT'} | '
        'Conf: ${signal.confidence}% | RSI=${signal.rsi.toStringAsFixed(1)} '
        'MACD=${signal.macdLine.toStringAsFixed(4)}',
      );

      await svc.setLeverage(symbol, _config.leverage);
      await svc.placeMarketOrder(symbol: symbol, side: side, quantity: quantity);

      final sl = signal.type == TradeSignalType.buy
          ? currentPrice * (1 - _config.stopLossPct / 100)
          : currentPrice * (1 + _config.stopLossPct / 100);
      final tp = signal.type == TradeSignalType.buy
          ? currentPrice * (1 + _config.takeProfitPct / 100)
          : currentPrice * (1 - _config.takeProfitPct / 100);

      await svc.placeStopMarketOrder(
          symbol: symbol, side: closeSide, quantity: quantity, stopPrice: sl);
      await svc.placeTakeProfitOrder(
          symbol: symbol, side: closeSide, quantity: quantity, stopPrice: tp);

      _addLog(symbol, 'PLACED',
          'SL=\$${sl.toStringAsFixed(2)} TP=\$${tp.toStringAsFixed(2)} Qty=${quantity.toStringAsFixed(4)}');

      await refreshData();
    } catch (e) {
      _addLog(symbol, 'ERR', e.toString(), isError: true);
    }
  }

  // ─── Multi-Indicator Signal Analysis (8 indicators, 100 pts total) ──────────

  TradeSignal _analyzeSignal(String symbol, List<List<double>> klines) {
    final closes = klines.map((k) => k[3]).toList();
    final volumes = klines.map((k) => k[4]).toList();
    final price = closes.last;

    if (closes.length < 50) {
      return TradeSignal(
          symbol: symbol, type: TradeSignalType.neutral, price: price, confidence: 0, indicators: []);
    }

    final ema9List = _calcEMA(closes, 9);
    final ema21List = _calcEMA(closes, 21);
    final ema50List = _calcEMA(closes, 50);
    final macdResult = _calcMACD(closes);
    final bbResult = _calcBB(closes, 20, 2.0);
    final rsi = _calcRSI(closes, 14);
    final stochRsi = _calcStochRSI(closes, 14, 14);
    final volumeRatio = _calcVolumeRatio(volumes, 20);

    final ema9 = ema9List.isNotEmpty ? ema9List.last : price;
    final ema21 = ema21List.isNotEmpty ? ema21List.last : price;
    final ema50 = ema50List.isNotEmpty ? ema50List.last : price;
    final ema9Prev = ema9List.length >= 2 ? ema9List[ema9List.length - 2] : ema9;
    final ema21Prev = ema21List.length >= 2 ? ema21List[ema21List.length - 2] : ema21;

    final macdLine = macdResult.$1;
    final macdSigLine = macdResult.$2;
    final macd = macdLine.isNotEmpty ? macdLine.last : 0.0;
    final macdSig = macdSigLine.isNotEmpty ? macdSigLine.last : 0.0;
    final macdPrev = macdLine.length >= 2 ? macdLine[macdLine.length - 2] : macd;
    final macdSigPrev = macdSigLine.length >= 2 ? macdSigLine[macdSigLine.length - 2] : macdSig;
    final macdHist = macd - macdSig;

    final bbUpper = bbResult.$1;
    final bbMid = bbResult.$2;
    final bbLower = bbResult.$3;

    int buyScore = 0, sellScore = 0;
    final indicators = <IndicatorResult>[];

    // === 1. EMA 9/21 Crossover (15 pts) ===
    final emaCrossUp = ema9Prev <= ema21Prev && ema9 > ema21;
    final emaCrossDown = ema9Prev >= ema21Prev && ema9 < ema21;
    if (emaCrossUp) {
      buyScore += 15;
      indicators.add(const IndicatorResult(
          name: 'EMA 9/21', verdict: 'BULL', score: 15, maxScore: 15, detail: 'Golden cross ↑'));
    } else if (emaCrossDown) {
      sellScore += 15;
      indicators.add(const IndicatorResult(
          name: 'EMA 9/21', verdict: 'BEAR', score: 15, maxScore: 15, detail: 'Death cross ↓'));
    } else if (ema9 > ema21) {
      buyScore += 8;
      indicators.add(const IndicatorResult(
          name: 'EMA 9/21', verdict: 'BULL', score: 8, maxScore: 15, detail: 'Bullish alignment'));
    } else {
      sellScore += 8;
      indicators.add(const IndicatorResult(
          name: 'EMA 9/21', verdict: 'BEAR', score: 8, maxScore: 15, detail: 'Bearish alignment'));
    }

    // === 2. EMA 50 Trend Filter (10 pts) ===
    if (price > ema50) {
      buyScore += 10;
      indicators.add(const IndicatorResult(
          name: 'EMA 50', verdict: 'BULL', score: 10, maxScore: 10, detail: 'Price above trend'));
    } else {
      sellScore += 10;
      indicators.add(const IndicatorResult(
          name: 'EMA 50', verdict: 'BEAR', score: 10, maxScore: 10, detail: 'Price below trend'));
    }

    // === 3. RSI (15 pts) ===
    if (rsi >= 50 && rsi <= 70) {
      buyScore += 15;
      indicators.add(IndicatorResult(
          name: 'RSI(14)', verdict: 'BULL', score: 15, maxScore: 15,
          detail: 'Bullish zone ${rsi.toStringAsFixed(0)}'));
    } else if (rsi <= 50 && rsi >= 30) {
      sellScore += 15;
      indicators.add(IndicatorResult(
          name: 'RSI(14)', verdict: 'BEAR', score: 15, maxScore: 15,
          detail: 'Bearish zone ${rsi.toStringAsFixed(0)}'));
    } else if (rsi < 30) {
      buyScore += 10;
      indicators.add(IndicatorResult(
          name: 'RSI(14)', verdict: 'BULL', score: 10, maxScore: 15,
          detail: 'Oversold ${rsi.toStringAsFixed(0)} — bounce'));
    } else {
      sellScore += 10;
      indicators.add(IndicatorResult(
          name: 'RSI(14)', verdict: 'BEAR', score: 10, maxScore: 15,
          detail: 'Overbought ${rsi.toStringAsFixed(0)} — pullback'));
    }

    // === 4. MACD Crossover (20 pts) ===
    final macdCrossUp = macdPrev <= macdSigPrev && macd > macdSig;
    final macdCrossDown = macdPrev >= macdSigPrev && macd < macdSig;
    if (macdCrossUp) {
      buyScore += 20;
      indicators.add(const IndicatorResult(
          name: 'MACD', verdict: 'BULL', score: 20, maxScore: 20, detail: 'Bullish crossover ↑'));
    } else if (macdCrossDown) {
      sellScore += 20;
      indicators.add(const IndicatorResult(
          name: 'MACD', verdict: 'BEAR', score: 20, maxScore: 20, detail: 'Bearish crossover ↓'));
    } else if (macd > macdSig) {
      buyScore += 12;
      indicators.add(const IndicatorResult(
          name: 'MACD', verdict: 'BULL', score: 12, maxScore: 20, detail: 'MACD above signal'));
    } else {
      sellScore += 12;
      indicators.add(const IndicatorResult(
          name: 'MACD', verdict: 'BEAR', score: 12, maxScore: 20, detail: 'MACD below signal'));
    }

    // === 5. MACD Zero Line (5 pts, folded into buyScore/sellScore) ===
    if (macd > 0) {
      buyScore += 5;
    } else {
      sellScore += 5;
    }

    // === 6. Bollinger Bands (10 pts) ===
    final bbRange = bbUpper - bbLower;
    final bbPos = bbRange > 0 ? (price - bbLower) / bbRange : 0.5;
    if (bbPos > 0.5 && bbPos <= 0.85) {
      buyScore += 10;
      indicators.add(const IndicatorResult(
          name: 'BB Bands', verdict: 'BULL', score: 10, maxScore: 10, detail: 'Mid-upper channel'));
    } else if (bbPos < 0.5 && bbPos >= 0.15) {
      sellScore += 10;
      indicators.add(const IndicatorResult(
          name: 'BB Bands', verdict: 'BEAR', score: 10, maxScore: 10, detail: 'Mid-lower channel'));
    } else if (bbPos < 0.15) {
      buyScore += 6;
      indicators.add(const IndicatorResult(
          name: 'BB Bands', verdict: 'BULL', score: 6, maxScore: 10, detail: 'Near lower support'));
    } else {
      sellScore += 6;
      indicators.add(const IndicatorResult(
          name: 'BB Bands', verdict: 'BEAR', score: 6, maxScore: 10, detail: 'Near upper resistance'));
    }

    // === 7. Volume (10 pts) ===
    if (volumeRatio >= 1.5) {
      final pts = volumeRatio >= 2.0 ? 10 : 7;
      final dir = buyScore >= sellScore;
      if (dir) buyScore += pts; else sellScore += pts;
      indicators.add(IndicatorResult(
          name: 'Volume', verdict: dir ? 'BULL' : 'BEAR', score: pts, maxScore: 10,
          detail: '${volumeRatio.toStringAsFixed(1)}x avg surge'));
    } else {
      indicators.add(IndicatorResult(
          name: 'Volume', verdict: 'NEUTRAL', score: 0, maxScore: 10,
          detail: '${volumeRatio.toStringAsFixed(1)}x avg (low)'));
    }

    // === 8. Stochastic RSI (15 pts) ===
    if (stochRsi <= 25) {
      buyScore += 15;
      indicators.add(IndicatorResult(
          name: 'StochRSI', verdict: 'BULL', score: 15, maxScore: 15,
          detail: 'Oversold ${stochRsi.toStringAsFixed(0)}'));
    } else if (stochRsi >= 75) {
      sellScore += 15;
      indicators.add(IndicatorResult(
          name: 'StochRSI', verdict: 'BEAR', score: 15, maxScore: 15,
          detail: 'Overbought ${stochRsi.toStringAsFixed(0)}'));
    } else if (stochRsi < 50) {
      buyScore += 7;
      indicators.add(IndicatorResult(
          name: 'StochRSI', verdict: 'BULL', score: 7, maxScore: 15,
          detail: 'Below midpoint ${stochRsi.toStringAsFixed(0)}'));
    } else {
      sellScore += 7;
      indicators.add(IndicatorResult(
          name: 'StochRSI', verdict: 'BEAR', score: 7, maxScore: 15,
          detail: 'Above midpoint ${stochRsi.toStringAsFixed(0)}'));
    }

    final confidence = max(buyScore, sellScore).clamp(0, 100);
    TradeSignalType type;
    if (buyScore > sellScore && confidence >= _config.confidenceThreshold) {
      type = TradeSignalType.buy;
    } else if (sellScore > buyScore && confidence >= _config.confidenceThreshold) {
      type = TradeSignalType.sell;
    } else {
      type = TradeSignalType.neutral;
    }

    return TradeSignal(
      symbol: symbol,
      type: type,
      price: price,
      confidence: confidence,
      indicators: indicators,
      ema9: ema9,
      ema21: ema21,
      ema50: ema50,
      rsi: rsi,
      macdLine: macd,
      macdSignalLine: macdSig,
      macdHist: macdHist,
      bbUpper: bbUpper,
      bbLower: bbLower,
      bbMid: bbMid,
      stochRsi: stochRsi,
      volumeRatio: volumeRatio,
    );
  }

  // ─── Indicator Calculations ───────────────────────────────────────────────

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

  // Returns (macdLine, signalLine, histogram) — all aligned to signalLine length
  (List<double>, List<double>, List<double>) _calcMACD(List<double> closes,
      {int fast = 12, int slow = 26, int signal = 9}) {
    final ema12 = _calcEMA(closes, fast);
    final ema26 = _calcEMA(closes, slow);
    if (ema12.isEmpty || ema26.isEmpty) return (<double>[], <double>[], <double>[]);
    final offset = ema12.length - ema26.length;
    final macdLine = List.generate(ema26.length, (i) => ema12[i + offset] - ema26[i]);
    final signalLine = _calcEMA(macdLine, signal);
    if (signalLine.isEmpty) return (macdLine, <double>[], <double>[]);
    final sigOffset = macdLine.length - signalLine.length;
    final histogram = List.generate(signalLine.length, (i) => macdLine[i + sigOffset] - signalLine[i]);
    return (macdLine.sublist(sigOffset), signalLine, histogram);
  }

  // Returns (upper, mid, lower)
  (double, double, double) _calcBB(List<double> closes, int period, double multiplier) {
    if (closes.length < period) return (closes.last, closes.last, closes.last);
    final recent = closes.sublist(closes.length - period);
    final sma = recent.reduce((a, b) => a + b) / period;
    final variance = recent.map((x) => (x - sma) * (x - sma)).reduce((a, b) => a + b) / period;
    final std = sqrt(variance);
    return (sma + multiplier * std, sma, sma - multiplier * std);
  }

  double _calcStochRSI(List<double> closes, int rsiPeriod, int stochPeriod) {
    if (closes.length < rsiPeriod + stochPeriod + 1) return 50;
    final startIdx = max(0, closes.length - stochPeriod - rsiPeriod - 1);
    final window = closes.sublist(startIdx);
    final rsiValues = <double>[];
    for (int i = rsiPeriod + 1; i <= window.length; i++) {
      rsiValues.add(_calcRSI(window.sublist(i - rsiPeriod - 1, i), rsiPeriod));
    }
    if (rsiValues.length < stochPeriod) return 50;
    final recent = rsiValues.sublist(rsiValues.length - stochPeriod);
    final maxRsi = recent.reduce((a, b) => a > b ? a : b);
    final minRsi = recent.reduce((a, b) => a < b ? a : b);
    if (maxRsi == minRsi) return 50;
    return ((rsiValues.last - minRsi) / (maxRsi - minRsi) * 100).clamp(0.0, 100.0);
  }

  double _calcVolumeRatio(List<double> volumes, int period) {
    if (volumes.length < period + 1) return 1.0;
    final avg = volumes.sublist(volumes.length - period - 1, volumes.length - 1).reduce((a, b) => a + b) / period;
    return avg <= 0 ? 1.0 : volumes.last / avg;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

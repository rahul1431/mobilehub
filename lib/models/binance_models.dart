class BinancePosition {
  final String symbol;
  final double positionAmt;
  final double entryPrice;
  final double markPrice;
  final double unrealizedProfit;
  final int leverage;
  final String marginType;

  const BinancePosition({
    required this.symbol,
    required this.positionAmt,
    required this.entryPrice,
    required this.markPrice,
    required this.unrealizedProfit,
    required this.leverage,
    required this.marginType,
  });

  factory BinancePosition.fromJson(Map<String, dynamic> j) {
    return BinancePosition(
      symbol: j['symbol'] ?? '',
      positionAmt: double.tryParse(j['positionAmt']?.toString() ?? '0') ?? 0,
      entryPrice: double.tryParse(j['entryPrice']?.toString() ?? '0') ?? 0,
      markPrice: double.tryParse(j['markPrice']?.toString() ?? '0') ?? 0,
      unrealizedProfit: double.tryParse(j['unRealizedProfit']?.toString() ?? '0') ?? 0,
      leverage: int.tryParse(j['leverage']?.toString() ?? '1') ?? 1,
      marginType: j['marginType'] ?? 'cross',
    );
  }

  bool get isOpen => positionAmt.abs() > 0.000001;
  bool get isLong => positionAmt > 0;

  double get pnlPercent {
    if (entryPrice <= 0 || positionAmt.abs() <= 0) return 0;
    final margin = (entryPrice * positionAmt.abs()) / leverage;
    if (margin <= 0) return 0;
    return (unrealizedProfit / margin) * 100;
  }
}

class BinanceBalance {
  final String asset;
  final double walletBalance;
  final double crossUnPnl;
  final double availableBalance;

  const BinanceBalance({
    required this.asset,
    required this.walletBalance,
    required this.crossUnPnl,
    required this.availableBalance,
  });

  factory BinanceBalance.fromJson(Map<String, dynamic> j) {
    return BinanceBalance(
      asset: j['asset'] ?? '',
      walletBalance: double.tryParse(j['walletBalance']?.toString() ?? '0') ?? 0,
      crossUnPnl: double.tryParse(j['crossUnPnl']?.toString() ?? '0') ?? 0,
      availableBalance: double.tryParse(j['availableBalance']?.toString() ?? '0') ?? 0,
    );
  }
}

class BinanceOrder {
  final int orderId;
  final String symbol;
  final String status;
  final String side;
  final String type;
  final double price;
  final double origQty;
  final double executedQty;

  const BinanceOrder({
    required this.orderId,
    required this.symbol,
    required this.status,
    required this.side,
    required this.type,
    required this.price,
    required this.origQty,
    required this.executedQty,
  });

  factory BinanceOrder.fromJson(Map<String, dynamic> j) {
    return BinanceOrder(
      orderId: (j['orderId'] ?? 0) is int ? j['orderId'] : int.tryParse(j['orderId'].toString()) ?? 0,
      symbol: j['symbol'] ?? '',
      status: j['status'] ?? '',
      side: j['side'] ?? '',
      type: j['type'] ?? '',
      price: double.tryParse(j['price']?.toString() ?? '0') ?? 0,
      origQty: double.tryParse(j['origQty']?.toString() ?? '0') ?? 0,
      executedQty: double.tryParse(j['executedQty']?.toString() ?? '0') ?? 0,
    );
  }
}

class TradeConfig {
  final String apiKey;
  final String apiSecret;
  final List<String> tradingPairs;
  final int leverage;
  final double positionSizePct;
  final double stopLossPct;
  final double takeProfitPct;
  final bool useTestnet;
  final int confidenceThreshold;

  const TradeConfig({
    required this.apiKey,
    required this.apiSecret,
    required this.tradingPairs,
    required this.leverage,
    required this.positionSizePct,
    required this.stopLossPct,
    required this.takeProfitPct,
    required this.useTestnet,
    this.confidenceThreshold = 75,
  });

  factory TradeConfig.defaults() => const TradeConfig(
        apiKey: '',
        apiSecret: '',
        tradingPairs: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'],
        leverage: 10,
        positionSizePct: 10.0,
        stopLossPct: 2.0,
        takeProfitPct: 4.0,
        useTestnet: true,
        confidenceThreshold: 75,
      );

  TradeConfig copyWith({
    String? apiKey,
    String? apiSecret,
    List<String>? tradingPairs,
    int? leverage,
    double? positionSizePct,
    double? stopLossPct,
    double? takeProfitPct,
    bool? useTestnet,
    int? confidenceThreshold,
  }) {
    return TradeConfig(
      apiKey: apiKey ?? this.apiKey,
      apiSecret: apiSecret ?? this.apiSecret,
      tradingPairs: tradingPairs ?? this.tradingPairs,
      leverage: leverage ?? this.leverage,
      positionSizePct: positionSizePct ?? this.positionSizePct,
      stopLossPct: stopLossPct ?? this.stopLossPct,
      takeProfitPct: takeProfitPct ?? this.takeProfitPct,
      useTestnet: useTestnet ?? this.useTestnet,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'apiSecret': apiSecret,
        'tradingPairs': tradingPairs,
        'leverage': leverage,
        'positionSizePct': positionSizePct,
        'stopLossPct': stopLossPct,
        'takeProfitPct': takeProfitPct,
        'useTestnet': useTestnet,
        'confidenceThreshold': confidenceThreshold,
      };

  factory TradeConfig.fromJson(Map<String, dynamic> j) {
    return TradeConfig(
      apiKey: j['apiKey'] ?? '',
      apiSecret: j['apiSecret'] ?? '',
      tradingPairs: List<String>.from(j['tradingPairs'] ?? ['BTCUSDT']),
      leverage: j['leverage'] ?? 10,
      positionSizePct: (j['positionSizePct'] ?? 10.0).toDouble(),
      stopLossPct: (j['stopLossPct'] ?? 2.0).toDouble(),
      takeProfitPct: (j['takeProfitPct'] ?? 4.0).toDouble(),
      useTestnet: j['useTestnet'] ?? true,
      confidenceThreshold: j['confidenceThreshold'] ?? 75,
    );
  }
}

enum TradeSignalType { buy, sell, neutral }

class IndicatorResult {
  final String name;
  final String verdict; // 'BULL', 'BEAR', 'NEUTRAL'
  final int score;
  final int maxScore;
  final String detail;

  const IndicatorResult({
    required this.name,
    required this.verdict,
    required this.score,
    required this.maxScore,
    required this.detail,
  });
}

class TradeSignal {
  final String symbol;
  final TradeSignalType type;
  final double price;
  final double ema9;
  final double ema21;
  final double ema50;
  final double rsi;
  final double macdLine;
  final double macdSignalLine;
  final double macdHist;
  final double bbUpper;
  final double bbLower;
  final double bbMid;
  final double stochRsi;
  final double volumeRatio;
  final int confidence;
  final List<IndicatorResult> indicators;
  final DateTime timestamp;

  TradeSignal({
    required this.symbol,
    required this.type,
    required this.price,
    required this.confidence,
    required this.indicators,
    this.ema9 = 0,
    this.ema21 = 0,
    this.ema50 = 0,
    this.rsi = 50,
    this.macdLine = 0,
    this.macdSignalLine = 0,
    this.macdHist = 0,
    this.bbUpper = 0,
    this.bbLower = 0,
    this.bbMid = 0,
    this.stochRsi = 50,
    this.volumeRatio = 1.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class CryptoNews {
  final String id;
  final String title;
  final String body;
  final String sourceName;
  final String sourceIcon;
  final String imageUrl;
  final String url;
  final DateTime publishedAt;
  final String categories;

  const CryptoNews({
    required this.id,
    required this.title,
    required this.body,
    required this.sourceName,
    required this.sourceIcon,
    required this.imageUrl,
    required this.url,
    required this.publishedAt,
    required this.categories,
  });

  factory CryptoNews.fromJson(Map<String, dynamic> j) {
    final ts = j['published_on'] ?? 0;
    return CryptoNews(
      id: j['id']?.toString() ?? '',
      title: j['title'] ?? '',
      body: j['body'] ?? '',
      sourceName: j['source_info']?['name'] ?? j['source'] ?? 'Unknown',
      sourceIcon: j['source_info']?['img'] ?? '',
      imageUrl: j['imageurl'] ?? '',
      url: j['url'] ?? '',
      publishedAt: DateTime.fromMillisecondsSinceEpoch((ts as int) * 1000),
      categories: j['categories'] ?? '',
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class TradeLog {
  final DateTime timestamp;
  final String symbol;
  final String action;
  final String message;
  final bool isError;

  const TradeLog({
    required this.timestamp,
    required this.symbol,
    required this.action,
    required this.message,
    this.isError = false,
  });
}

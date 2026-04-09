class AlphaSignal {
  final String symbol;
  final double price;
  final String direction;
  final double target;
  final double stop;
  final String strategy;
  final int confidence;
  final DateTime timestamp;

  AlphaSignal({
    required this.symbol,
    required this.price,
    required this.direction,
    required this.target,
    required this.stop,
    required this.strategy,
    required this.confidence,
    required this.timestamp,
  });

  factory AlphaSignal.fromJson(Map<String, dynamic> json) {
    return AlphaSignal(
      symbol: json['symbol'] ?? '---',
      price: (json['price'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 'BUY',
      target: (json['tp'] ?? 0.0).toDouble(),
      stop: (json['sl'] ?? 0.0).toDouble(),
      strategy: json['strategy'] ?? 'V-Pressure',
      confidence: json['confidence'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class TradeHistory {
  final String symbol;
  final String direction;
  final double entryPrice;
  final double exitPrice;
  final double yield;
  final String result;
  final DateTime timestamp;

  TradeHistory({
    required this.symbol,
    required this.direction,
    required this.entryPrice,
    required this.exitPrice,
    required this.yield,
    required this.result,
    required this.timestamp,
  });

  factory TradeHistory.fromJson(Map<String, dynamic> json) {
    return TradeHistory(
      symbol: json['symbol'] ?? '---',
      direction: json['direction'] ?? 'BUY',
      entryPrice: (json['entryPrice'] ?? 0.0).toDouble(),
      exitPrice: (json['exitPrice'] ?? 0.0).toDouble(),
      yield: (json['changePct'] ?? 0.0).toDouble(),
      result: json['result'] ?? 'NEUTRAL',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

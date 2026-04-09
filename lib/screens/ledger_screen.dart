import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/app_theme.dart';
import '../widgets/glass_card.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock ledger data
    final List<TradeHistory> mockHistory = [
      TradeHistory(symbol: "BTCUSDT", direction: "BUY", entryPrice: 65200, exitPrice: 67100, yield: 2.91, result: "PROFIT", timestamp: DateTime.now()),
      TradeHistory(symbol: "SOLUSDT", direction: "SELL", entryPrice: 185, exitPrice: 178, yield: 3.78, result: "PROFIT", timestamp: DateTime.now()),
      TradeHistory(symbol: "ETHUSDT", direction: "BUY", entryPrice: 3500, exitPrice: 3450, yield: -1.42, result: "LOSS", timestamp: DateTime.now()),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [Color(0xFF10192B), AppTheme.bgMain],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text("Performance Ledger", style: TextStyle(fontSize: 24, fontWeight: FontWeight.black, color: Colors.white)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: mockHistory.length,
                  itemBuilder: (context, index) => _buildLedgerTile(mockHistory[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerTile(TradeHistory trade) {
    final isProfit = trade.result == "PROFIT";
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4, height: 40,
            decoration: BoxDecoration(
              color: isProfit ? AppTheme.success : AppTheme.danger,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trade.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text("${trade.direction} @ \$${trade.entryPrice}", style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isProfit ? '+' : ''}${trade.yield}%",
                style: TextStyle(color: isProfit ? AppTheme.success : AppTheme.danger, fontWeight: FontWeight.w900, fontSize: 16),
              ),
              Text(trade.result, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

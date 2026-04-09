import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/signal_card.dart';
import '../core/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for initial blueprint
    final List<AlphaSignal> mockSignals = [
      AlphaSignal(symbol: "BTCUSDT", price: 68450.25, direction: "BUY", target: 71200, stop: 67100, strategy: "Alpha-Omega", confidence: 92, timestamp: DateTime.now()),
      AlphaSignal(symbol: "ETHUSDT", price: 3420.15, direction: "BUY", target: 3650, stop: 3310, strategy: "Trend-Pulse", confidence: 88, timestamp: DateTime.now()),
      AlphaSignal(symbol: "SOLUSDT", price: 178.45, direction: "SELL", target: 162, stop: 185, strategy: "V-Pressure", confidence: 75, timestamp: DateTime.now()),
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
                child: Text("Alpha Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.black, color: Colors.white)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: mockSignals.length,
                  itemBuilder: (context, index) => SignalCard(signal: mockSignals[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

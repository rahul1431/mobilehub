import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/binance_models.dart';
import '../services/auto_trade_service.dart';
import '../widgets/confidence_meter.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutoTradeService>().analyzeMarketSignals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoTradeService>(
      builder: (context, svc, _) => Scaffold(
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
              children: [
                _buildHeader(svc),
                Expanded(
                  child: svc.isLoadingSignals
                      ? _buildLoading()
                      : svc.marketSignals.isEmpty
                          ? _buildEmpty(svc)
                          : RefreshIndicator(
                              color: AppTheme.primary,
                              backgroundColor: AppTheme.bgGlass,
                              onRefresh: svc.analyzeMarketSignals,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                                itemCount: svc.marketSignals.length,
                                itemBuilder: (_, i) => _buildSignalCard(svc.marketSignals[i], svc),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AutoTradeService svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Signals',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const Text('8-Indicator Confidence Engine • 1H Candles',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: svc.isLoadingSignals ? null : svc.analyzeMarketSignals,
            icon: svc.isLoadingSignals
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                : const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalCard(TradeSignal signal, AutoTradeService svc) {
    final isBuy = signal.type == TradeSignalType.buy;
    final isSell = signal.type == TradeSignalType.sell;
    final sideColor = isBuy ? AppTheme.success : (isSell ? AppTheme.danger : AppTheme.textMuted);
    final threshold = svc.config.confidenceThreshold;
    final meetsThreshold = signal.confidence >= threshold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: meetsThreshold ? sideColor.withOpacity(0.3) : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          childrenPadding: EdgeInsets.zero,
          leading: ConfidenceMeter(confidence: signal.confidence, size: 56, showLabel: true),
          title: Row(
            children: [
              Text(signal.symbol,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isBuy || isSell ? sideColor : Colors.white).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBuy ? '▲ LONG' : (isSell ? '▼ SHORT' : 'WAIT'),
                  style: TextStyle(
                      color: isBuy || isSell ? sideColor : AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${signal.price > 100 ? signal.price.toStringAsFixed(2) : signal.price.toStringAsFixed(4)}',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                const SizedBox(height: 4),
                ConfidenceBar(confidence: signal.confidence),
                const SizedBox(height: 2),
                Text(
                  meetsThreshold
                      ? 'Signal active — ${signal.confidence}% ≥ $threshold% threshold'
                      : '${signal.confidence}% < $threshold% threshold — no trade',
                  style: TextStyle(
                      color: meetsThreshold ? sideColor.withOpacity(0.7) : AppTheme.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text('INDICATOR BREAKDOWN',
                        style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2)),
                  ),
                  ...signal.indicators.map(_buildIndicatorRow),
                  const Divider(color: Colors.white10),
                  _buildPriceGrid(signal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(IndicatorResult ind) {
    final isBull = ind.verdict == 'BULL';
    final isBear = ind.verdict == 'BEAR';
    final color = isBull ? AppTheme.success : (isBear ? AppTheme.danger : AppTheme.textMuted);
    final pct = ind.maxScore > 0 ? ind.score / ind.maxScore : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 76,
            child: Text(ind.name,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.white.withOpacity(0.07),
                valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${ind.score}/${ind.maxScore}',
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w800),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(ind.verdict,
                style: TextStyle(
                    color: color, fontSize: 8, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceGrid(TradeSignal signal) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip('RSI', signal.rsi.toStringAsFixed(1)),
          _chip('EMA9', _fmt(signal.ema9)),
          _chip('EMA21', _fmt(signal.ema21)),
          _chip('EMA50', _fmt(signal.ema50)),
          _chip('MACD', signal.macdLine.toStringAsFixed(4)),
          _chip('BB Mid', _fmt(signal.bbMid)),
          _chip('StochRSI', signal.stochRsi.toStringAsFixed(1)),
          _chip('Vol×', signal.volumeRatio.toStringAsFixed(2)),
        ],
      ),
    );
  }

  String _fmt(double p) => p > 100 ? p.toStringAsFixed(1) : p.toStringAsFixed(4);

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w700)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
          SizedBox(height: 16),
          Text('Running 8-indicator analysis...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          SizedBox(height: 6),
          Text('EMA • RSI • MACD • BB • StochRSI • Volume',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEmpty(AutoTradeService svc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          const Text('No signals yet',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tap refresh to run market analysis',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: svc.analyzeMarketSignals,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Analyze Now'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}

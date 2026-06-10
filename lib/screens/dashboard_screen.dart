import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/binance_models.dart';
import '../services/auto_trade_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/confidence_meter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<AutoTradeService>();
      if (svc.config.apiKey.isNotEmpty) svc.refreshData();
      if (svc.marketSignals.isEmpty) svc.analyzeMarketSignals();
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
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.bgGlass,
              onRefresh: () async {
                await svc.refreshData();
                await svc.analyzeMarketSignals();
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(svc),
                  const SizedBox(height: 20),
                  _buildWalletCard(svc),
                  const SizedBox(height: 16),
                  _buildBotStatus(svc),
                  const SizedBox(height: 16),
                  _buildMetricsRow(svc),
                  const SizedBox(height: 16),
                  _buildSignalsPreview(svc),
                  const SizedBox(height: 16),
                  _buildPerformanceReport(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AutoTradeService svc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alpha Hub',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(
              svc.isRunning ? '● Bot Active' : 'Probing Market Pulse...',
              style: TextStyle(
                color: svc.isRunning ? AppTheme.success : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withOpacity(0.1),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: const Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 22),
        ),
      ],
    );
  }

  Widget _buildWalletCard(AutoTradeService svc) {
    final bal = svc.balance;
    final pnl = bal?.crossUnPnl ?? 0;
    final pnlColor = pnl >= 0 ? AppTheme.success : AppTheme.danger;
    final hasKeys = svc.config.apiKey.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accent, size: 15),
                  SizedBox(width: 6),
                  Text('FUTURES WALLET',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (svc.config.useTestnet ? AppTheme.primary : AppTheme.danger).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  svc.config.useTestnet ? 'TESTNET' : 'LIVE',
                  style: TextStyle(
                    color: svc.config.useTestnet ? AppTheme.primary : AppTheme.danger,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bal != null) ...[
            Text('\$${bal.walletBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
            Text('Wallet Balance',
                style: TextStyle(
                    color: AppTheme.textMuted.withOpacity(0.7), fontSize: 11)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _walletItem('Available',
                    '\$${bal.availableBalance.toStringAsFixed(2)}', AppTheme.primary)),
                Container(width: 1, height: 32, color: Colors.white10),
                Expanded(child: _walletItem('Unrealized PnL',
                    '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}', pnlColor)),
                Container(width: 1, height: 32, color: Colors.white10),
                Expanded(child: _walletItem('Open Positions',
                    '${svc.positions.length}', AppTheme.accent)),
              ],
            ),
          ] else
            _noWallet(hasKeys),
        ],
      ),
    );
  }

  Widget _walletItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _noWallet(bool hasKeys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(hasKeys ? Icons.sync_rounded : Icons.link_off_rounded,
              color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 10),
          Text(
            hasKeys ? 'Pull down to refresh balance' : 'Connect Binance API in Profile',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBotStatus(AutoTradeService svc) {
    final running = svc.isRunning;
    final color = running ? AppTheme.success : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: running
                  ? [BoxShadow(color: AppTheme.success.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(running ? 'Auto Trader Running' : 'Auto Trader Idle',
                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                Text(svc.status,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              running
                  ? '${svc.config.leverage}x • ${svc.config.useTestnet ? "TEST" : "LIVE"}'
                  : 'IDLE',
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(AutoTradeService svc) {
    final signals = svc.marketSignals;
    final bullish = signals.where((s) => s.type == TradeSignalType.buy).length;
    final bearish = signals.where((s) => s.type == TradeSignalType.sell).length;
    final avgConf = signals.isEmpty
        ? 0
        : signals.map((s) => s.confidence).reduce((a, b) => a + b) ~/ signals.length;

    return Row(
      children: [
        Expanded(child: _metricCard('AVG CONF.', '$avgConf%', AppTheme.primary, Icons.psychology_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('BULLISH', '$bullish', AppTheme.success, Icons.trending_up_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard('BEARISH', '$bearish', AppTheme.danger, Icons.trending_down_rounded)),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color color, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildSignalsPreview(AutoTradeService svc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Live Signals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            if (svc.isLoadingSignals)
              const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 10),
        if (svc.marketSignals.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: const Text('Loading market signals...',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          )
        else
          ...svc.marketSignals.take(3).map(_signalRow),
      ],
    );
  }

  Widget _signalRow(TradeSignal signal) {
    final isBuy = signal.type == TradeSignalType.buy;
    final isSell = signal.type == TradeSignalType.sell;
    final color = isBuy ? AppTheme.success : (isSell ? AppTheme.danger : AppTheme.textMuted);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          ConfidenceMeter(confidence: signal.confidence, size: 40, showLabel: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(signal.symbol,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                Text(
                  '\$${signal.price > 100 ? signal.price.toStringAsFixed(2) : signal.price.toStringAsFixed(4)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isBuy ? '▲ LONG' : (isSell ? '▼ SHORT' : 'WAIT'),
                    style: TextStyle(
                        color: color, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 3),
              Text('${signal.confidence}% conf.',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Performance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('DAILY',
                  style: TextStyle(
                      color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              _reportRow('Best 24h Signal', '+12.4%', AppTheme.success),
              const Divider(color: Colors.white10),
              _reportRow('Expected Value (EV)', '\$4,250', AppTheme.accent),
              const Divider(color: Colors.white10),
              _reportRow('Win Streak', '8', AppTheme.success),
              const Divider(color: Colors.white10),
              _reportRow('Signals Today', '24', AppTheme.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../models/binance_models.dart';
import '../services/auto_trade_service.dart';
import '../widgets/glass_card.dart';
import 'bot_settings_screen.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutoTradeService>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoTradeService>(
      builder: (context, svc, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [Color(0xFF0B1A10), AppTheme.bgMain],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, svc),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.bgGlass,
                      onRefresh: svc.refreshData,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        children: [
                          _buildStatusBanner(svc),
                          _buildBalanceCard(svc),
                          _buildConfigRow(svc),
                          _buildPositionsSection(svc),
                          _buildLogSection(svc),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFAB(context, svc),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AutoTradeService svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Auto Trader',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(
                  'Binance Futures • ${svc.config.leverage}x • 8 Indicators • ${svc.config.confidenceThreshold}%+ confidence',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: svc.refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textMuted),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BotSettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(AutoTradeService svc) {
    final active = svc.isRunning;
    final color = active ? AppTheme.success : AppTheme.textMuted;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Animated dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: active
                  ? [BoxShadow(color: AppTheme.success.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(svc.status,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(active ? 'LIVE' : 'IDLE',
                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AutoTradeService svc) {
    final bal = svc.balance;
    final pnl = bal?.crossUnPnl ?? 0;
    final pnlColor = pnl >= 0 ? AppTheme.success : AppTheme.danger;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _balStat('AVAILABLE', bal != null ? '\$${bal.availableBalance.toStringAsFixed(2)}' : '--', AppTheme.primary)),
          _vDivider(),
          Expanded(child: _balStat('WALLET BAL.', bal != null ? '\$${bal.walletBalance.toStringAsFixed(2)}' : '--', Colors.white)),
          _vDivider(),
          Expanded(
            child: _balStat(
              'UNREAL. PNL',
              bal != null ? '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}' : '--',
              pnlColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: Colors.white10);

  Widget _balStat(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildConfigRow(AutoTradeService svc) {
    final cfg = svc.config;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _cfgItem(Icons.bolt_rounded, '${cfg.leverage}x', 'LEVERAGE', AppTheme.accent),
          _cfgItem(Icons.pie_chart_outline_rounded, '${cfg.positionSizePct.toStringAsFixed(0)}%', 'POS SIZE', AppTheme.primary),
          _cfgItem(Icons.shield_outlined, '${cfg.stopLossPct}%', 'STOP LOSS', AppTheme.danger),
          _cfgItem(Icons.flag_outlined, '${cfg.takeProfitPct}%', 'TAKE PROFIT', AppTheme.success),
          _cfgItem(Icons.psychology_rounded, '${cfg.confidenceThreshold}%', 'MIN CONF', AppTheme.accent),
          _cfgItem(
            cfg.useTestnet ? Icons.science_outlined : Icons.public_rounded,
            cfg.useTestnet ? 'TEST' : 'LIVE',
            'NETWORK',
            cfg.useTestnet ? AppTheme.textMuted : AppTheme.danger,
          ),
        ],
      ),
    );
  }

  Widget _cfgItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      ],
    );
  }

  Widget _buildPositionsSection(AutoTradeService svc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Open Positions',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              _badge('${svc.positions.length}', AppTheme.primary),
            ],
          ),
        ),
        if (svc.positions.isEmpty)
          _empty('No open positions', Icons.inbox_rounded)
        else
          ...svc.positions.map(_positionCard),
      ],
    );
  }

  Widget _positionCard(BinancePosition pos) {
    final pnlColor = pos.unrealizedProfit >= 0 ? AppTheme.success : AppTheme.danger;
    final sideColor = pos.isLong ? AppTheme.success : AppTheme.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: sideColor, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pos.symbol,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 6),
                    _badge(pos.isLong ? 'LONG' : 'SHORT', sideColor),
                    const SizedBox(width: 4),
                    _badge('${pos.leverage}x', AppTheme.accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Entry \$${pos.entryPrice.toStringAsFixed(2)}  •  Mark \$${pos.markPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pos.unrealizedProfit >= 0 ? '+' : ''}\$${pos.unrealizedProfit.toStringAsFixed(2)}',
                style: TextStyle(color: pnlColor, fontWeight: FontWeight.w900, fontSize: 15),
              ),
              Text(
                '${pos.pnlPercent >= 0 ? '+' : ''}${pos.pnlPercent.toStringAsFixed(2)}%',
                style: TextStyle(color: pnlColor.withOpacity(0.7), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogSection(AutoTradeService svc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Activity Log',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              _badge('${svc.logs.length}', AppTheme.textMuted),
            ],
          ),
        ),
        if (svc.logs.isEmpty)
          _empty('No activity yet', Icons.receipt_long_rounded)
        else
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: svc.logs.take(25).map(_logRow).toList(),
            ),
          ),
      ],
    );
  }

  Widget _logRow(TradeLog log) {
    final Color color;
    switch (log.action) {
      case 'BUY':
        color = AppTheme.success;
        break;
      case 'SELL':
        color = AppTheme.danger;
        break;
      case 'START':
        color = AppTheme.primary;
        break;
      case 'STOP':
        color = AppTheme.textMuted;
        break;
      case 'ERR':
      case 'ERROR':
        color = AppTheme.danger;
        break;
      default:
        color = AppTheme.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(log.action, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '[${log.symbol}] ${log.message}',
              style: TextStyle(color: log.isError ? AppTheme.danger.withOpacity(0.8) : AppTheme.textMuted, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _empty(String msg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textMuted.withOpacity(0.25), size: 32),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: AppTheme.textMuted.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, AutoTradeService svc) {
    final running = svc.isRunning;
    return FloatingActionButton.extended(
      onPressed: () async {
        if (running) {
          svc.stop();
        } else {
          if (svc.config.apiKey.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configure API keys in Settings first'),
                backgroundColor: AppTheme.danger,
              ),
            );
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BotSettingsScreen()));
            return;
          }
          await svc.start();
        }
      },
      backgroundColor: running ? AppTheme.danger.withOpacity(0.85) : AppTheme.success.withOpacity(0.85),
      elevation: 4,
      icon: Icon(running ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white),
      label: Text(
        running ? 'STOP BOT' : 'START BOT',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2),
      ),
    );
  }
}

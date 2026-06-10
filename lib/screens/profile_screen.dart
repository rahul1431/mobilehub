import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../services/auto_trade_service.dart';
import '../widgets/glass_card.dart';
import 'bot_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _traderName = 'Trader';
  bool _editingName = false;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutoTradeService>().refreshData();
    });
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('trader_name') ?? 'Trader';
    if (mounted) {
      setState(() {
        _traderName = name;
        _nameCtrl.text = name;
      });
    }
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trader_name', name);
    if (mounted) setState(() { _traderName = name; _editingName = false; });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutoTradeService>(
      builder: (context, svc, _) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [Color(0xFF0E0B1E), AppTheme.bgMain],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.bgGlass,
              onRefresh: svc.refreshData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  _buildProfileHeader(svc),
                  const SizedBox(height: 24),
                  _buildConnectionCard(svc),
                  const SizedBox(height: 12),
                  _buildWalletCard(svc),
                  const SizedBox(height: 12),
                  _buildBotStatsCard(svc),
                  const SizedBox(height: 12),
                  _buildQuickActions(context, svc),
                  const SizedBox(height: 24),
                  _buildRiskDisclaimer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AutoTradeService svc) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 40),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: svc.isRunning ? AppTheme.success : AppTheme.textMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bgMain, width: 2),
              ),
              child: Icon(
                svc.isRunning ? Icons.smart_toy_rounded : Icons.power_settings_new_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_editingName)
          SizedBox(
            width: 180,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _saveName(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_rounded, color: AppTheme.success, size: 18),
                  onPressed: _saveName,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _editingName = true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_traderName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_rounded, color: AppTheme.textMuted, size: 14),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          svc.config.useTestnet ? '● Testnet Mode' : '● Live Trading',
          style: TextStyle(
            color: svc.config.useTestnet ? AppTheme.primary : AppTheme.danger,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(AutoTradeService svc) {
    final hasKeys = svc.config.apiKey.isNotEmpty;
    final keyPreview = hasKeys
        ? '${svc.config.apiKey.substring(0, min(8, svc.config.apiKey.length))}••••••••'
        : 'Not configured';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.link_rounded, color: AppTheme.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Binance Futures',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasKeys ? AppTheme.success : AppTheme.danger).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasKeys ? 'CONNECTED' : 'NOT SET',
                  style: TextStyle(
                    color: hasKeys ? AppTheme.success : AppTheme.danger,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          if (hasKeys) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.key_rounded, 'API Key', keyPreview),
            const SizedBox(height: 6),
            _infoRow(
              svc.config.useTestnet ? Icons.science_rounded : Icons.public_rounded,
              'Network',
              svc.config.useTestnet ? 'Testnet (Safe)' : 'Live (Real Funds)',
              valueColor: svc.config.useTestnet ? AppTheme.primary : AppTheme.danger,
            ),
            const SizedBox(height: 6),
            _infoRow(Icons.tune_rounded, 'Confidence Min', '${svc.config.confidenceThreshold}%',
                valueColor: AppTheme.accent),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Configure API keys to connect',
                  style: TextStyle(color: AppTheme.textMuted.withOpacity(0.6), fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(AutoTradeService svc) {
    final bal = svc.balance;
    final pnl = bal?.crossUnPnl ?? 0;
    final pnlColor = pnl >= 0 ? AppTheme.success : AppTheme.danger;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppTheme.accent, size: 16),
              SizedBox(width: 8),
              Text('Futures Wallet',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          if (bal != null) ...[
            Row(
              children: [
                Expanded(
                  child: _walletStat(
                    'WALLET BALANCE',
                    '\$${bal.walletBalance.toStringAsFixed(2)}',
                    Colors.white,
                  ),
                ),
                Expanded(
                  child: _walletStat(
                    'AVAILABLE',
                    '\$${bal.availableBalance.toStringAsFixed(2)}',
                    AppTheme.primary,
                  ),
                ),
                Expanded(
                  child: _walletStat(
                    'UNREALIZED PNL',
                    '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                    pnlColor,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              svc.config.apiKey.isEmpty
                  ? 'Connect API keys to see balance'
                  : 'Pull to refresh balance',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildBotStatsCard(AutoTradeService svc) {
    final logs = svc.logs;
    final totalScans = logs.where((l) => l.action == 'SCAN' || l.action == 'BUY' || l.action == 'SELL').length;
    final buys = logs.where((l) => l.action == 'BUY').length;
    final sells = logs.where((l) => l.action == 'SELL').length;
    final errors = logs.where((l) => l.isError).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: AppTheme.success, size: 16),
              SizedBox(width: 8),
              Text('Bot Activity',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statChip('SCANS', '$totalScans', AppTheme.textMuted)),
              Expanded(child: _statChip('LONGS', '$buys', AppTheme.success)),
              Expanded(child: _statChip('SHORTS', '$sells', AppTheme.danger)),
              Expanded(child: _statChip('ERRORS', '$errors', errors > 0 ? AppTheme.danger : AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  svc.isRunning ? Icons.circle : Icons.radio_button_unchecked,
                  color: svc.isRunning ? AppTheme.success : AppTheme.textMuted,
                  size: 10,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    svc.status,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AutoTradeService svc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10, left: 4),
          child: Text('QUICK ACTIONS',
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _actionTile(
                context,
                Icons.tune_rounded,
                'Bot Settings',
                'Configure API keys, leverage & pairs',
                AppTheme.accent,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BotSettingsScreen())),
              ),
              const Divider(color: Colors.white10, height: 1),
              _actionTile(
                context,
                svc.isRunning ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
                svc.isRunning ? 'Stop Trading Bot' : 'Start Trading Bot',
                svc.isRunning ? 'Currently running — tap to stop' : 'Bot is idle — tap to start',
                svc.isRunning ? AppTheme.danger : AppTheme.success,
                () async {
                  if (svc.isRunning) {
                    svc.stop();
                  } else {
                    if (svc.config.apiKey.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Configure API keys first'),
                          backgroundColor: AppTheme.danger));
                    } else {
                      await svc.start();
                    }
                  }
                },
              ),
              const Divider(color: Colors.white10, height: 1),
              _actionTile(
                context,
                Icons.refresh_rounded,
                'Refresh Wallet',
                'Fetch latest balance from Binance',
                AppTheme.primary,
                () => svc.refreshData(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
    );
  }

  Widget _buildRiskDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withOpacity(0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Trading cryptocurrency futures involves significant risk. This bot is provided for educational purposes only. Never trade with money you cannot afford to lose.',
              style: TextStyle(color: AppTheme.danger, fontSize: 10, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 13),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _walletStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 8, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

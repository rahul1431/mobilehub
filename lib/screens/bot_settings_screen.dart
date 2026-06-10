import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../models/binance_models.dart';
import '../services/auto_trade_service.dart';
import '../widgets/glass_card.dart';

class BotSettingsScreen extends StatefulWidget {
  const BotSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BotSettingsScreen> createState() => _BotSettingsScreenState();
}

class _BotSettingsScreenState extends State<BotSettingsScreen> {
  final _apiKeyCtrl = TextEditingController();
  final _apiSecretCtrl = TextEditingController();
  bool _secretVisible = false;
  bool _useTestnet = true;
  int _leverage = 10;
  double _positionSizePct = 10.0;
  double _stopLossPct = 2.0;
  double _takeProfitPct = 4.0;
  int _confidenceThreshold = 75;
  List<String> _selectedPairs = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];
  bool _isSaving = false;

  static const _allPairs = [
    'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT',
    'XRPUSDT', 'DOGEUSDT', 'ADAUSDT', 'LINKUSDT',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromService();
  }

  void _loadFromService() {
    final cfg = context.read<AutoTradeService>().config;
    _apiKeyCtrl.text = cfg.apiKey;
    _apiSecretCtrl.text = cfg.apiSecret;
    _useTestnet = cfg.useTestnet;
    _leverage = cfg.leverage;
    _positionSizePct = cfg.positionSizePct;
    _stopLossPct = cfg.stopLossPct;
    _takeProfitPct = cfg.takeProfitPct;
    _confidenceThreshold = cfg.confidenceThreshold;
    _selectedPairs = List.from(cfg.tradingPairs);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final cfg = TradeConfig(
      apiKey: _apiKeyCtrl.text.trim(),
      apiSecret: _apiSecretCtrl.text.trim(),
      tradingPairs: _selectedPairs.isEmpty ? ['BTCUSDT'] : _selectedPairs,
      leverage: _leverage,
      positionSizePct: _positionSizePct,
      stopLossPct: _stopLossPct,
      takeProfitPct: _takeProfitPct,
      useTestnet: _useTestnet,
      confidenceThreshold: _confidenceThreshold,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('trade_config', json.encode(cfg.toJson()));

    if (mounted) {
      context.read<AutoTradeService>().updateConfig(cfg);
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [Color(0xFF0A1020), AppTheme.bgMain],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  children: [
                    _sectionLabel('API CREDENTIALS'),
                    GlassCard(
                      child: Column(
                        children: [
                          _networkToggle(),
                          const SizedBox(height: 16),
                          _textField(
                            ctrl: _apiKeyCtrl,
                            label: 'API Key',
                            icon: Icons.key_rounded,
                            obscure: false,
                          ),
                          const SizedBox(height: 12),
                          _textField(
                            ctrl: _apiSecretCtrl,
                            label: 'API Secret',
                            icon: Icons.lock_rounded,
                            obscure: !_secretVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _secretVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _secretVisible = !_secretVisible),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _sectionLabel('RISK MANAGEMENT'),
                    GlassCard(
                      child: Column(
                        children: [
                          _slider('Leverage', '${_leverage}x', _leverage.toDouble(), 1, 20,
                              (v) => setState(() => _leverage = v.round()), color: AppTheme.accent),
                          _divider(),
                          _slider('Position Size', '${_positionSizePct.round()}%', _positionSizePct, 1, 50,
                              (v) => setState(() => _positionSizePct = v), color: AppTheme.primary),
                          _divider(),
                          _slider('Stop Loss', '${_stopLossPct.toStringAsFixed(1)}%', _stopLossPct, 0.5, 10,
                              (v) => setState(() => _stopLossPct = v), color: AppTheme.danger, divisions: 19),
                          _divider(),
                          _slider('Take Profit', '${_takeProfitPct.toStringAsFixed(1)}%', _takeProfitPct, 1, 20,
                              (v) => setState(() => _takeProfitPct = v), color: AppTheme.success, divisions: 19),
                          _divider(),
                          _slider('AI Confidence Min', '$_confidenceThreshold%', _confidenceThreshold.toDouble(), 50, 95,
                              (v) => setState(() => _confidenceThreshold = v.round()),
                              color: AppTheme.accent, divisions: 45),
                        ],
                      ),
                    ),
                    _sectionLabel('TRADING PAIRS'),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select pairs to trade (tap to toggle)',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _allPairs.map(_pairChip).toList(),
                          ),
                        ],
                      ),
                    ),
                    _sectionLabel('STRATEGY INFO'),
                    GlassCard(
                      child: Column(
                        children: [
                          _infoRow(Icons.show_chart_rounded, 'EMA 9/21 Crossover', '15 pts — Golden/death cross entry signal'),
                          _divider(),
                          _infoRow(Icons.trending_up_rounded, 'EMA 50 Trend', '10 pts — Medium-term trend filter'),
                          _divider(),
                          _infoRow(Icons.analytics_rounded, 'RSI(14)', '15 pts — Momentum confirmation'),
                          _divider(),
                          _infoRow(Icons.swap_horiz_rounded, 'MACD(12,26,9)', '20 pts — Primary momentum signal'),
                          _divider(),
                          _infoRow(Icons.compress_rounded, 'Bollinger Bands(20)', '10 pts — Volatility context'),
                          _divider(),
                          _infoRow(Icons.bar_chart_rounded, 'Volume', '10 pts — Volume surge confirmation'),
                          _divider(),
                          _infoRow(Icons.stacked_line_chart_rounded, 'StochRSI(14)', '15 pts — Short-term momentum'),
                          _divider(),
                          _infoRow(Icons.timer_rounded, 'Scan Interval', 'Markets scanned every 5 minutes'),
                          _divider(),
                          _infoRow(Icons.account_balance_wallet_rounded, 'Position Sizing',
                              '${_positionSizePct.round()}% of available balance × ${_leverage}x leverage'),
                        ],
                      ),
                    ),
                    _buildWarningCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _saveBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Bot Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    );
  }

  Widget _networkToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Testnet Mode', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(
              _useTestnet ? 'testnet.binancefuture.com' : 'fapi.binance.com (REAL MONEY)',
              style: TextStyle(color: _useTestnet ? AppTheme.textMuted : AppTheme.danger, fontSize: 10),
            ),
          ],
        ),
        Switch(
          value: _useTestnet,
          onChanged: (v) {
            if (!v) {
              _showLiveWarning(() => setState(() => _useTestnet = false));
            } else {
              setState(() => _useTestnet = true);
            }
          },
          activeColor: AppTheme.success,
          activeTrackColor: AppTheme.success.withOpacity(0.3),
          inactiveThumbColor: AppTheme.danger,
          inactiveTrackColor: AppTheme.danger.withOpacity(0.3),
        ),
      ],
    );
  }

  void _showLiveWarning(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1627),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            SizedBox(width: 8),
            Text('Live Trading', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          'You are switching to LIVE trading with REAL funds on Binance. '
          'This bot will place real orders. Only proceed if you fully understand the risks.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('I Understand', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required bool obscure,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        prefixIcon: Icon(icon, color: AppTheme.accent, size: 18),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
      ),
    );
  }

  Widget _slider(
    String label,
    String display,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    Color color = AppTheme.primary,
    int? divisions,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(display, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.12),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _pairChip(String pair) {
    final selected = _selectedPairs.contains(pair);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          if (_selectedPairs.length > 1) _selectedPairs.remove(pair);
        } else {
          _selectedPairs.add(pair);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.18) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary.withOpacity(0.6) : Colors.white12,
          ),
        ),
        child: Text(
          pair,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(desc, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => const Divider(color: Colors.white10, height: 20);

  Widget _buildWarningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.danger.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Cryptocurrency futures trading with leverage carries significant risk of loss. '
              'Past performance does not guarantee future results. Only trade with funds you can '
              'afford to lose entirely. Use Testnet mode for testing strategies.',
              style: TextStyle(color: AppTheme.danger, fontSize: 10, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                )
              : const Text(
                  'SAVE SETTINGS',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _apiSecretCtrl.dispose();
    super.dispose();
  }
}

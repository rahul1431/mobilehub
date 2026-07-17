import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../widgets/glass_card.dart';

/// Animated lottery result screen shown when cycle_method = 'lottery'
/// and a winner has been selected.
class LotteryResultScreen extends StatefulWidget {
  final String winnerName;
  final double totalPot;
  final double? winningBid;
  final double? dividendPerMember;
  final String groupName;
  final int cycleNumber;
  final bool isWinner;

  const LotteryResultScreen({
    super.key,
    required this.winnerName,
    required this.totalPot,
    required this.groupName,
    required this.cycleNumber,
    this.winningBid,
    this.dividendPerMember,
    this.isWinner = false,
  });

  @override
  State<LotteryResultScreen> createState() => _LotteryResultScreenState();
}

class _LotteryResultScreenState extends State<LotteryResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _spinAnim;
  late final Animation<double> _fadeAnim;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));

    _spinAnim = CurvedAnimation(parent: _ctrl, curve: Curves.decelerate);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.75, 1.0, curve: Curves.easeIn)),
    );

    _ctrl.forward().then((_) {
      if (mounted) setState(() => _revealed = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.groupName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Cycle #${widget.cycleNumber} — Lottery',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinning wheel animation
              AnimatedBuilder(
                animation: _spinAnim,
                builder: (_, child) => Transform.rotate(
                  angle: _spinAnim.value * 6 * pi,
                  child: child,
                ),
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(colors: [
                      AppTheme.primary, AppTheme.gold,
                      AppTheme.warning, AppTheme.success,
                      AppTheme.primary,
                    ]),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.gold.withOpacity(0.4), blurRadius: 30),
                    ],
                  ),
                  child: const Icon(Icons.stars_rounded,
                      color: Colors.white, size: 56),
                ),
              ),

              const SizedBox(height: 40),

              // Winner reveal
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(children: [
                  if (widget.isWinner) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.gold, Color(0xFFFF9900)]),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text('🎉 You Won!',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    widget.isWinner ? 'Congratulations!' : 'Winner Announced',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.winnerName,
                    style: const TextStyle(
                        color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('has won Cycle #${widget.cycleNumber}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),

                  const SizedBox(height: 32),

                  GlassCard(
                    child: Column(children: [
                      _detail('Total Pot',
                          '₹${widget.totalPot.toStringAsFixed(0)}', AppTheme.gold),
                      if (widget.dividendPerMember != null) ...[
                        const SizedBox(height: 12),
                        _detail('Your Dividend',
                            '₹${widget.dividendPerMember!.toStringAsFixed(2)}',
                            widget.isWinner ? AppTheme.textMuted : AppTheme.success),
                      ],
                    ]),
                  ),

                  const SizedBox(height: 32),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Group'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      minimumSize: const Size(200, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ]),
              ),

              if (!_revealed) ...[
                const SizedBox(height: 40),
                const Text('Drawing the winner…',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value, Color color) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ]);
}

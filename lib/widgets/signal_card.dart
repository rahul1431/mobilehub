import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/app_theme.dart';
import 'glass_card.dart';

class SignalCard extends StatelessWidget {
  final AlphaSignal signal;

  const SignalCard({Key? key, required this.signal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.direction == 'BUY';
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isBuy ? AppTheme.success : AppTheme.danger).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBuy ? "BULLISH ALPHA" : "BEARISH ALPHA",
                  style: TextStyle(
                    color: isBuy ? AppTheme.success : AppTheme.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.show_chart, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            signal.symbol,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.black, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${signal.price.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLevel("TARGET", "\$${signal.target.toStringAsFixed(2)}", AppTheme.success),
              const SizedBox(width: 16),
              _buildLevel("STOP", "\$${signal.stop.toStringAsFixed(2)}", AppTheme.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevel(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

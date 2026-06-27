import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../providers/auth_provider.dart';

class MemberDashboardTab extends StatelessWidget {
  const MemberDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Namaste, ${profile?.displayName ?? 'Member'} 👋',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Here\'s your savings summary', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const SizedBox(height: 20),

          // Savings summary card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Invested', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 6),
                const Text('₹0', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  _miniStat('Dividends Earned', '₹0', AppTheme.success),
                  const SizedBox(width: 24),
                  _miniStat('Next Due', 'N/A', AppTheme.warning),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard('Active Chits', '0', Icons.group_work_rounded, AppTheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Won Chits', '0', Icons.emoji_events_rounded, AppTheme.gold)),
          ]),

          const SizedBox(height: 24),
          const Text('My Chit Groups', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Center(
              child: Text('No chit groups yet.\nYour agent will add you to a group.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../widgets/glass_card.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statCard('Total Providers', '—', Icons.people_alt_rounded, AppTheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Active Groups', '—', Icons.group_work_rounded, AppTheme.accent)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('Total Members', '—', Icons.person_rounded, AppTheme.success)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Monthly AUM', '₹—', Icons.account_balance_rounded, AppTheme.gold)),
          ]),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _actionTile(Icons.add_circle_rounded, 'Create Package', 'Define a new chit template', AppTheme.primary),
                _actionTile(Icons.person_add_rounded, 'Add Provider', 'Onboard a new chit agent', AppTheme.accent),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _actionTile(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
      ]),
    );
  }
}

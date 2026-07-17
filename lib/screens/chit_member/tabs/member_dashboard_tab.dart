import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/glass_card.dart';

class MemberDashboardTab extends StatefulWidget {
  const MemberDashboardTab({super.key});

  @override
  State<MemberDashboardTab> createState() => _MemberDashboardTabState();
}

class _MemberDashboardTabState extends State<MemberDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final state = context.watch<MemberProvider>();
    final data  = state.dashData;

    return RefreshIndicator(
      onRefresh: () => state.loadDashboard(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Namaste, ${auth.profile?.displayName ?? 'Member'} 🙏',
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Your savings at a glance',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            const SizedBox(height: 20),

            // ── Main savings card ─────────────────────────────────────────
            if (state.dashLoading && data == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Invested',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${_fmt(data?['total_invested'])}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      _mini('Dividends Earned', '₹${_fmt(data?['total_dividends'])}',
                          AppTheme.success),
                      const SizedBox(width: 24),
                      if (data?['next_payment'] != null)
                        _mini(
                          'Next Due',
                          _formatDue(data?['next_payment']),
                          AppTheme.warning,
                        )
                      else
                        _mini('Next Due', 'None pending', AppTheme.textMuted),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Stat chips ─────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: _statCard(
                    'Active Chits',
                    '${data?['active_groups'] ?? 0}',
                    Icons.group_work_rounded,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Won Chits',
                    '${data?['won_chits'] ?? 0}',
                    Icons.emoji_events_rounded,
                    AppTheme.gold,
                  ),
                ),
              ]),

              // ── Next payment card ──────────────────────────────────────
              if (data?['next_payment'] != null) ...[
                const SizedBox(height: 20),
                const Text('Upcoming Payment',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _NextPaymentCard(payment: data!['next_payment'] as Map<String, dynamic>),
              ],

              // ── No groups placeholder ──────────────────────────────────
              if ((data?['active_groups'] ?? 0) == 0 &&
                  (data?['total_invested'] ?? 0) == 0) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  child: const Center(
                    child: Text(
                      'No chit groups yet.\nYour agent will add you to a group soon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final d = (v as num).toDouble();
    if (d >= 100000) return '${(d / 100000).toStringAsFixed(1)}L';
    if (d >= 1000)   return '${(d / 1000).toStringAsFixed(1)}K';
    return d.toStringAsFixed(0);
  }

  String _formatDue(Map<String, dynamic>? np) {
    if (np == null) return 'N/A';
    final due = np['due_date'];
    if (due == null) return '₹${_fmt(np['amount'])}';
    final dt = DateTime.tryParse(due.toString());
    if (dt == null) return '₹${_fmt(np['amount'])}';
    return DateFormat('dd MMM').format(dt);
  }

  Widget _mini(String label, String value, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ]);

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
      );
}

// ── Next Payment Card ─────────────────────────────────────────────────────────

class _NextPaymentCard extends StatelessWidget {
  const _NextPaymentCard({required this.payment});
  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    final amount   = (payment['amount'] as num? ?? 0).toDouble();
    final group    = payment['group'] as String? ?? 'Chit Group';
    final dueRaw   = payment['due_date'];
    final dueDate  = dueRaw != null ? DateTime.tryParse(dueRaw.toString()) : null;

    final daysLeft = dueDate != null
        ? dueDate.difference(DateTime.now()).inDays
        : null;

    final urgency = daysLeft != null && daysLeft <= 3
        ? AppTheme.error
        : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgency.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: urgency.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.calendar_month_rounded, color: urgency, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            if (dueDate != null)
              Text(
                'Due ${DateFormat('dd MMM yyyy').format(dueDate)}'
                '${daysLeft != null ? "  ($daysLeft days left)" : ""}',
                style: TextStyle(color: urgency, fontSize: 12),
              ),
          ]),
        ),
        Text('₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
                color: urgency, fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

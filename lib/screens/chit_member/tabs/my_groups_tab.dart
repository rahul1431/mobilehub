import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/glass_card.dart';

class MyGroupsTab extends StatefulWidget {
  const MyGroupsTab({super.key});

  @override
  State<MyGroupsTab> createState() => _MyGroupsTabState();
}

class _MyGroupsTabState extends State<MyGroupsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadMyGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MemberProvider>();

    return RefreshIndicator(
      onRefresh: () => state.loadMyGroups(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: state.groupsLoading && state.myGroups.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : state.myGroups.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Column(children: [
                        Icon(Icons.group_work_rounded, color: AppTheme.textMuted, size: 56),
                        SizedBox(height: 16),
                        Text('No chit groups yet',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Your agent will add you to a chit group soon.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted)),
                      ]),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.myGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _GroupCard(group: state.myGroups[i] as Map<String, dynamic>),
                ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final Map<String, dynamic> group;

  @override
  Widget build(BuildContext context) {
    final name    = group['name'] as String? ?? 'Chit Group';
    final status  = group['status'] as String? ?? 'forming';
    final cycle   = group['current_cycle'] as int? ?? 0;
    final total   = group['total_members'] as int? ?? 0;
    final pkg     = group['package'] as Map<String, dynamic>?;
    final monthly = pkg != null ? (pkg['monthly_amount'] as num?)?.toDouble() : null;

    final Color statusColor = switch (status) {
      'active'    => AppTheme.success,
      'completed' => AppTheme.primary,
      _           => AppTheme.warning,
    };

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _Badge(label: status.toUpperCase(), color: statusColor),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          _Info(icon: Icons.people_rounded, text: '$total members'),
          const SizedBox(width: 20),
          _Info(icon: Icons.refresh_rounded, text: 'Cycle $cycle'),
          if (monthly != null) ...[
            const SizedBox(width: 20),
            _Info(
              icon: Icons.currency_rupee_rounded,
              text: '₹${monthly.toStringAsFixed(0)}/mo',
            ),
          ],
        ]),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppTheme.textMuted, size: 14),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
  ]);
}

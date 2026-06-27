import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_group_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/provider_state.dart';
import '../groups/create_group_screen.dart';
import '../groups/group_detail_screen.dart';

class ProviderDashboardTab extends StatefulWidget {
  const ProviderDashboardTab({super.key});

  @override
  State<ProviderDashboardTab> createState() => _ProviderDashboardTabState();
}

class _ProviderDashboardTabState extends State<ProviderDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderState>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final state = context.watch<ProviderState>();
    final stats = state.dashStats;
    final groups = (stats?['groups'] as List<ChitGroupModel>? ?? []).take(3).toList();

    return RefreshIndicator(
      onRefresh: () => state.loadDashboard(),
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, ${auth.profile?.displayName ?? 'Agent'} 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Your Chit Dashboard', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ])),
            if (state.statsLoading)
              const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 20),

          // Stats grid
          GridView.count(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 1.4, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(label: 'Active Groups',
                  value: stats != null ? '${stats['active_groups'] ?? 0}' : '—',
                  icon: Icons.group_work_rounded, color: AppTheme.primary, loading: state.statsLoading),
              _StatCard(label: 'Forming',
                  value: stats != null ? '${stats['forming_groups'] ?? 0}' : '—',
                  icon: Icons.pending_actions_rounded, color: AppTheme.accent, loading: state.statsLoading),
              _StatCard(label: 'Total Members',
                  value: stats != null ? '${stats['total_members'] ?? 0}' : '—',
                  icon: Icons.people_rounded, color: AppTheme.success, loading: state.statsLoading),
              _StatCard(label: 'Completed',
                  value: stats != null ? '${stats['completed_groups'] ?? 0}' : '—',
                  icon: Icons.check_circle_rounded, color: AppTheme.textMuted, loading: state.statsLoading),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _QuickAction(
            icon: Icons.add_circle_rounded, title: 'Create Chit Group',
            subtitle: 'Start a new group from a package', color: AppTheme.primary,
            onTap: () async {
              final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
              if (ok == true && mounted) state.loadDashboard();
            },
          ),
          const SizedBox(height: 10),
          _QuickAction(
            icon: Icons.payments_rounded, title: 'Record Payment',
            subtitle: 'Mark a cash or bank payment', color: AppTheme.accent,
            onTap: () {
              // Navigate to groups tab index 1 — handled by shell
            },
          ),
          const SizedBox(height: 24),

          // Recent groups
          if (groups.isNotEmpty) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Groups', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('See all', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 8),
            ...groups.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _RecentGroupRow(group: g,
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GroupDetailScreen(group: g)))),
            )),
          ],
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool loading;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 22),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          loading
              ? SizedBox(width: 40, height: 22, child: LinearProgressIndicator(
                  backgroundColor: color.withOpacity(0.1), color: color,
                  borderRadius: BorderRadius.circular(4)))
              : Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ]),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        ])),
      ),
    );
  }
}

class _RecentGroupRow extends StatelessWidget {
  final ChitGroupModel group;
  final VoidCallback onTap;
  const _RecentGroupRow({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = group.isActive ? AppTheme.primary : group.isForming ? AppTheme.accent : AppTheme.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.group_work_rounded, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${group.membershipsCount ?? 0}/${group.totalMembers} members · Cycle ${group.currentCycle}',
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(group.statusLabel, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
        ]),
      ),
    );
  }
}

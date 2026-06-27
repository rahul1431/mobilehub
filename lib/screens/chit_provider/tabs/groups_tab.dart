import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_group_model.dart';
import '../../../providers/provider_state.dart';
import '../groups/create_group_screen.dart';
import '../groups/group_detail_screen.dart';

class GroupsTab extends StatefulWidget {
  const GroupsTab({super.key});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderState>().loadGroups();
    });
  }

  Future<void> _openCreate() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    if (result == true && mounted) context.read<ProviderState>().loadGroups();
  }

  void _openDetail(ChitGroupModel group) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
      body: Consumer<ProviderState>(builder: (_, state, __) {
        if (state.groupsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (state.groupsError != null && state.groups.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(state.groupsError!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => state.loadGroups(), child: const Text('Retry')),
          ]));
        }
        final filtered = state.groups.where((g) => _filter == 'all' || g.status == _filter).toList();
        return Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              for (final f in ['all', 'forming', 'active', 'completed'])
                Padding(padding: const EdgeInsets.only(right: 8), child: _FilterChip(
                  label: f == 'all' ? 'All (${state.groups.length})' : '${_cap(f)} (${state.groups.where((g) => g.status == f).length})',
                  selected: _filter == f, onTap: () => setState(() => _filter = f),
                )),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.group_work_outlined, color: AppTheme.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(state.groups.isEmpty ? 'No groups yet' : 'No $_filter groups',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    if (state.groups.isEmpty)
                      const Text('Tap + to create your first chit group', style: TextStyle(color: AppTheme.textMuted)),
                  ]))
                : RefreshIndicator(
                    onRefresh: () => state.loadGroups(),
                    color: AppTheme.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _GroupCard(
                        group: filtered[i],
                        onTap: () => _openDetail(filtered[i]),
                        onDelete: () => _confirmDelete(context, state, filtered[i]),
                      ),
                    ),
                  ),
          ),
        ]);
      }),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ProviderState state, ChitGroupModel g) async {
    if (g.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete an active group'), backgroundColor: AppTheme.error));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Group', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${g.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (ok == true && context.mounted) await state.deleteGroup(g.id);
  }

  String _cap(String s) => s[0].toUpperCase() + s.substring(1);
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : Colors.white12),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textMuted,
          fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        )),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final ChitGroupModel group;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _GroupCard({required this.group, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final pkg = group.package;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor().withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 12, 10), child: Row(children: [
            Container(width: 42, height: 42,
                decoration: BoxDecoration(color: _borderColor().withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.group_work_rounded, color: _borderColor(), size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(group.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(pkg?.name ?? 'No package', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            _StatusBadge(group.statusLabel, _borderColor()),
            PopupMenuButton<String>(
              color: AppTheme.surface,
              icon: const Icon(Icons.more_vert, color: Colors.white38),
              onSelected: (v) { if (v == 'delete') onDelete(); },
              itemBuilder: (_) => [const PopupMenuItem(value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: AppTheme.error, size: 18), SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppTheme.error)),
                  ]))],
            ),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${group.membershipsCount ?? 0}/${group.totalMembers} members',
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Text('Cycle ${group.currentCycle}/${pkg?.durationMonths ?? '?'}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: group.fillPct, backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(_borderColor()), minHeight: 4,
            )),
          ])),
          if (pkg != null) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 14), child: Row(children: [
            _stat('Monthly', '₹${_f(pkg.monthlyAmount)}'), _divider(),
            _stat('Total Pot', '₹${_f(pkg.totalPot)}'), _divider(),
            _stat('Commission', '${pkg.commissionPct.toStringAsFixed(1)}%'),
          ])),
          const SizedBox(height: 2),
        ]),
      ),
    );
  }

  Color _borderColor() {
    switch (group.status) {
      case 'active':    return AppTheme.primary;
      case 'forming':   return AppTheme.accent;
      default:          return AppTheme.textMuted;
    }
  }

  Widget _stat(String l, String v) => Expanded(child: Column(children: [
    Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    Text(l, style: const TextStyle(color: Colors.white54, fontSize: 10)),
  ]));
  Widget _divider() => Container(width: 1, height: 28, color: Colors.white12);
  String _f(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatusBadge extends StatelessWidget {
  final String label; final Color color;
  const _StatusBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

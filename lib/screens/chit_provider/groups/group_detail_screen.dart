import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_group_model.dart';
import '../../../models/group_membership_model.dart';
import '../../../providers/provider_state.dart';

class GroupDetailScreen extends StatefulWidget {
  final ChitGroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderState>().loadGroupDetail(widget.group.id);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.bgMain,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(group.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF004D39), AppTheme.bgMain],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 56),
                  child: Row(children: [
                    _chip(group.statusLabel, _statusColor(group.status)),
                    const SizedBox(width: 8),
                    _chip('Cycle ${group.currentCycle}/${group.package?.durationMonths ?? '?'}', AppTheme.accent),
                    const SizedBox(width: 8),
                    _chip('${group.membershipsCount ?? 0}/${group.totalMembers} members', AppTheme.primary),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textMuted,
              tabs: const [
                Tab(text: 'Members'),
                Tab(text: 'Cycles'),
                Tab(text: 'Info'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _MembersTab(group: group),
            _CyclesTab(group: group),
            _InfoTab(group: group),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active':    return AppTheme.success;
      case 'forming':   return AppTheme.accent;
      case 'completed': return AppTheme.primary;
      default:          return AppTheme.textMuted;
    }
  }
}

// ── Members Tab ──────────────────────────────────────────────────────────────

class _MembersTab extends StatelessWidget {
  final ChitGroupModel group;
  const _MembersTab({required this.group});

  void _showAddMember(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const Text('Add Member', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixText: '+91 ',
                  prefixStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    String phone = ctrl.text.trim();
                    if (phone.length < 10) return;
                    if (!phone.startsWith('+')) phone = '+91$phone';
                    setSt(() => saving = true);
                    final ok = await context.read<ProviderState>().addMember(group.id, phone);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.read<ProviderState>().groupDetailError ?? 'Failed'),
                          backgroundColor: AppTheme.error,
                        ));
                      }
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Add to Group'),
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderState>(builder: (_, state, __) {
      final members = state.selectedGroupMembers.where((m) => m.isActive).toList();
      final slotsLeft = group.totalMembers - members.length;

      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: slotsLeft > 0
            ? FloatingActionButton.extended(
                onPressed: () => _showAddMember(context),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.person_add_outlined),
                label: Text('Add ($slotsLeft slots)'),
              )
            : null,
        body: state.groupDetailLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : members.isEmpty
                ? const Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline, color: AppTheme.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text('No members yet', style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Tap + to add members', style: TextStyle(color: AppTheme.textMuted)),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MemberRow(
                      member: members[i],
                      onRemove: () => _confirmRemove(context, state, members[i]),
                    ),
                  ),
      );
    });
  }

  Future<void> _confirmRemove(BuildContext context, ProviderState state, GroupMemberModel m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Remove Member', style: TextStyle(color: Colors.white)),
        content: Text('Remove ${m.displayName} from this group?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await state.removeMember(group.id, m.memberId);
    }
  }
}

class _MemberRow extends StatelessWidget {
  final GroupMemberModel member;
  final VoidCallback onRemove;
  const _MemberRow({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: member.hasWon ? AppTheme.gold.withOpacity(0.4) : Colors.white12),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: member.hasWon
              ? AppTheme.gold.withOpacity(0.2)
              : AppTheme.primary.withOpacity(0.12),
          child: Text(
            '#${member.membershipNo}',
            style: TextStyle(
              color: member.hasWon ? AppTheme.gold : AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(member.displayName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              if (member.hasWon) ...[
                const SizedBox(width: 6),
                const Icon(Icons.emoji_events, color: AppTheme.gold, size: 14),
              ],
            ]),
            Text(member.phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: member.isKycVerified
                ? AppTheme.success.withOpacity(0.15)
                : AppTheme.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            member.kycStatus,
            style: TextStyle(
              color: member.isKycVerified ? AppTheme.success : AppTheme.warning,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 18),
          onPressed: onRemove,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ]),
    );
  }
}

// ── Cycles Tab ───────────────────────────────────────────────────────────────

class _CyclesTab extends StatelessWidget {
  final ChitGroupModel group;
  const _CyclesTab({required this.group});

  void _showStartCycle(BuildContext context, ProviderState state) {
    String method = 'manual';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Text('Start New Cycle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Cycle #${group.currentCycle + 1} of ${group.package?.durationMonths ?? '?'}',
                style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Winner Selection Method', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            const SizedBox(height: 10),
            _MethodTile(value: 'manual', label: 'Manual Pick', icon: Icons.touch_app_outlined,
                desc: 'You choose the winner', selected: method == 'manual',
                onTap: () => setSt(() => method = 'manual')),
            _MethodTile(value: 'lottery', label: 'Lottery', icon: Icons.casino_outlined,
                desc: 'Random draw from eligible members', selected: method == 'lottery',
                onTap: () => setSt(() => method = 'lottery')),
            _MethodTile(value: 'auction', label: 'Online Auction', icon: Icons.gavel_outlined,
                desc: 'Members bid — lowest bid wins', selected: method == 'auction',
                onTap: () => setSt(() => method = 'auction')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await state.startCycle(group.id, method);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.groupDetailError ?? 'Failed to start cycle'),
                      backgroundColor: AppTheme.error,
                    ));
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Start Cycle'),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderState>(builder: (_, state, __) {
      final cycles = state.selectedGroupCycles;
      final canStart = group.isForming || (group.isActive &&
          (group.currentCycle < (group.package?.durationMonths ?? 0)));

      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: canStart
            ? FloatingActionButton.extended(
                onPressed: () => _showStartCycle(context, state),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Cycle'),
              )
            : null,
        body: cycles.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.loop_outlined, color: AppTheme.textMuted, size: 48),
                  const SizedBox(height: 12),
                  const Text('No cycles yet', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 6),
                  if (canStart)
                    const Text('Tap Start Cycle to begin', style: TextStyle(color: AppTheme.textMuted)),
                ]),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                itemCount: cycles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _CycleCard(
                  cycle: cycles[i],
                  members: state.selectedGroupMembers,
                  onPickWinner: (winnerId) => state.pickWinner(
                      cycles[i].id, cycles[i].cycleMethod, winnerId: winnerId),
                ),
              ),
      );
    });
  }
}

class _MethodTile extends StatelessWidget {
  final String value, label, desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.value, required this.label, required this.icon,
      required this.desc, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.primary : Colors.white12,
              width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? AppTheme.primary : AppTheme.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: selected ? AppTheme.primary : Colors.white,
                fontWeight: FontWeight.w600, fontSize: 13)),
            Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          if (selected) const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
        ]),
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  final dynamic cycle;
  final List<GroupMemberModel> members;
  final Future<bool> Function(int?) onPickWinner;
  const _CycleCard({required this.cycle, required this.members, required this.onPickWinner});

  @override
  Widget build(BuildContext context) {
    final isClosed = cycle.isClosed as bool;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isClosed ? Colors.white12 : AppTheme.accent.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Cycle #${cycle.cycleNumber}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isClosed ? AppTheme.success : AppTheme.accent).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isClosed ? 'Closed' : 'Open',
              style: TextStyle(
                color: isClosed ? AppTheme.success : AppTheme.accent,
                fontSize: 11, fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Due: ${_fmtDate(cycle.dueDate)}  ·  ${cycle.methodLabel}  ·  Pot: ₹${_f(cycle.totalPot)}',
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        if (isClosed && cycle.winnerName != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.emoji_events, color: AppTheme.gold, size: 16),
            const SizedBox(width: 6),
            Text('Winner: ${cycle.winnerName}',
                style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600)),
          ]),
        ],
        if (!isClosed) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () => _showPickWinner(context),
              icon: const Icon(Icons.how_to_vote_outlined, size: 16),
              label: const Text('Pick Winner', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ]),
    );
  }

  void _showPickWinner(BuildContext context) {
    final eligibleMembers = members.where((m) => m.isActive && !m.hasWon).toList();
    int? selectedId;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scroll) => Column(children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Text('Select Winner', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Cycle #${cycle.cycleNumber} · ${cycle.methodLabel}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: eligibleMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final m = eligibleMembers[i];
                  final sel = selectedId == m.memberId;
                  return GestureDetector(
                    onTap: () => setSt(() => selectedId = m.memberId),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppTheme.primary : Colors.white12),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 16, backgroundColor: AppTheme.primary.withOpacity(0.15),
                          child: Text('#${m.membershipNo}',
                              style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.displayName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(m.phone, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ])),
                        if (sel) const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                      ]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: selectedId == null ? null : () async {
                    Navigator.pop(ctx);
                    await onPickWinner(selectedId);
                  },
                  child: const Text('Confirm Winner'),
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _f(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Info Tab ─────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final ChitGroupModel group;
  const _InfoTab({required this.group});

  @override
  Widget build(BuildContext context) {
    final pkg = group.package;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _section('Group Details', [
          _row('Name', group.name),
          _row('Status', group.statusLabel),
          _row('Current Cycle', '${group.currentCycle} / ${pkg?.durationMonths ?? '?'}'),
          _row('Total Slots', group.totalMembers.toString()),
          _row('Members Joined', (group.membershipsCount ?? 0).toString()),
          if (group.startDate != null)
            _row('Start Date', '${group.startDate!.day}/${group.startDate!.month}/${group.startDate!.year}'),
        ]),
        if (pkg != null) ...[
          const SizedBox(height: 20),
          _section('Package Details', [
            _row('Package', pkg.name),
            _row('Monthly Amount', '₹${pkg.monthlyAmount.toStringAsFixed(0)}'),
            _row('Duration', '${pkg.durationMonths} months'),
            _row('Total Pot / Cycle', '₹${_f(pkg.totalPot)}'),
            _row('Commission Rate', '${pkg.commissionPct.toStringAsFixed(1)}%'),
            _row('Commission / Cycle', '₹${_f(pkg.commissionPerCycle)}'),
            _row('Member Net Payout', '₹${_f(pkg.memberNetPayout)}'),
          ]),
        ],
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _f(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

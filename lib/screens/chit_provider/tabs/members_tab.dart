import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/provider_state.dart';
import '../../../services/provider_api_service.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  List<dynamic> _members = [];
  bool _loading = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ProviderApiService().getAllMembers();
      if (mounted) setState(() { _members = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _members.where((m) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      final name = (m['full_name'] ?? '').toString().toLowerCase();
      final phone = (m['phone'] ?? '').toString();
      return name.contains(q) || phone.contains(q);
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _search = ''))
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(children: [
          Text('${filtered.length} members', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : filtered.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.people_outline, color: AppTheme.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(_search.isEmpty ? 'No members yet' : 'No results for "$_search"',
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    if (_search.isEmpty)
                      const Text('Add members through a group', style: TextStyle(color: AppTheme.textMuted)),
                  ]))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppTheme.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _MemberListTile(member: filtered[i]),
                    ),
                  ),
      ),
    ]);
  }
}

class _MemberListTile extends StatelessWidget {
  final dynamic member;
  const _MemberListTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member['full_name'] as String? ?? member['phone'] as String? ?? '';
    final phone = member['phone'] as String? ?? '';
    final kyc = member['kyc_status'] as String? ?? 'pending';
    final isVerified = kyc == 'verified';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primary.withOpacity(0.12),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          Text(phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (isVerified ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(kyc,
              style: TextStyle(
                color: isVerified ? AppTheme.success : AppTheme.warning,
                fontSize: 10, fontWeight: FontWeight.w600,
              )),
        ),
      ]),
    );
  }
}

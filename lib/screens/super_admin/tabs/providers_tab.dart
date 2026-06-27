import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/provider_model.dart';
import '../../../providers/admin_provider.dart';
import '../providers/add_provider_screen.dart';

class ProvidersTab extends StatefulWidget {
  const ProvidersTab({super.key});

  @override
  State<ProvidersTab> createState() => _ProvidersTabState();
}

class _ProvidersTabState extends State<ProvidersTab> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProviders();
    });
  }

  Future<void> _openAdd() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddProviderScreen()),
    );
    if (result == true && mounted) {
      context.read<AdminProvider>().loadProviders();
    }
  }

  Future<void> _confirmDelete(ProviderModel provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Remove Provider', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove ${provider.displayName} as a chit provider? Their account remains but role will be reset.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final admin = context.read<AdminProvider>();
      await admin.deleteProvider(provider.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Provider'),
      ),
      body: Consumer<AdminProvider>(
        builder: (_, admin, __) {
          if (admin.providersLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (admin.providersError != null && admin.providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(admin.providersError!,
                      style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => admin.loadProviders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filtered = admin.providers.where((p) {
            if (_search.isEmpty) return true;
            final q = _search.toLowerCase();
            return (p.fullName?.toLowerCase().contains(q) ?? false) ||
                p.phone.contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (admin.providers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    Text('${filtered.length} providers',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, color: AppTheme.textMuted, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              _search.isEmpty ? 'No providers yet' : 'No results for "$_search"',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_search.isEmpty)
                              const Text('Tap + to onboard your first chit provider',
                                  style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => admin.loadProviders(),
                        color: AppTheme.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ProviderCard(
                            provider: filtered[i],
                            onDelete: () => _confirmDelete(filtered[i]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final VoidCallback onDelete;

  const _ProviderCard({required this.provider, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            child: Text(
              provider.displayName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.displayName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(provider.phone,
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 6),
                Row(children: [
                  _badge(
                    label: provider.kycStatus,
                    color: provider.isKycVerified ? AppTheme.primary : AppTheme.warning,
                  ),
                  const SizedBox(width: 6),
                  if (provider.subscriptionPlan != null)
                    _badge(
                      label: provider.subscriptionPlan!,
                      color: AppTheme.accent,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.activeGroups} groups · ${provider.totalMembers} members',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ]),
              ],
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white38),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.error),
              title: const Text('Remove Provider', style: TextStyle(color: AppTheme.error)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

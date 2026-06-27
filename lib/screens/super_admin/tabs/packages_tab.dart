import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_package_model.dart';
import '../../../providers/admin_provider.dart';
import '../packages/create_package_screen.dart';

class PackagesTab extends StatefulWidget {
  const PackagesTab({super.key});

  @override
  State<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPackages();
    });
  }

  Future<void> _openCreate([ChitPackageModel? existing]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreatePackageScreen(existing: existing)),
    );
    if (result == true && mounted) {
      context.read<AdminProvider>().loadPackages();
    }
  }

  Future<void> _confirmDelete(ChitPackageModel pkg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Package', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${pkg.name}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final admin = context.read<AdminProvider>();
      final success = await admin.deletePackage(pkg.id);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(admin.packagesError ?? 'Delete failed'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Package'),
      ),
      body: Consumer<AdminProvider>(
        builder: (_, admin, __) {
          if (admin.packagesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (admin.packagesError != null && admin.packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(admin.packagesError!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => admin.loadPackages(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (admin.packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted, size: 56),
                  const SizedBox(height: 16),
                  const Text('No packages yet',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first chit template',
                      style: TextStyle(color: AppTheme.textMuted)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => admin.loadPackages(),
            color: AppTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: admin.packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PackageCard(
                package: admin.packages[i],
                onEdit: () => _openCreate(admin.packages[i]),
                onDelete: () => _confirmDelete(admin.packages[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final ChitPackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PackageCard({
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: package.isActive
              ? AppTheme.primary.withOpacity(0.3)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        '${package.durationMonths} months · ${package.maxMembers} members',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: package.isActive
                        ? AppTheme.primary.withOpacity(0.15)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    package.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: package.isActive ? AppTheme.primary : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _stat('Monthly', '₹${_fmt(package.monthlyAmount)}'),
                _divider(),
                _stat('Total Pot', '₹${_fmt(package.totalPot)}'),
                _divider(),
                _stat('Commission', '${package.commissionPct.toStringAsFixed(1)}%'),
                _divider(),
                _stat('Net Payout', '₹${_fmt(package.memberNetPayout)}', accent: true),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white12),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {bool accent = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                color: accent ? AppTheme.accent : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 30, color: Colors.white12);
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

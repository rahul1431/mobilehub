import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../packages/create_package_screen.dart';
import '../providers/add_provider_screen.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAnalytics();
    });
  }

  Future<void> _openCreatePackage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreatePackageScreen()),
    );
    if (result == true && mounted) {
      context.read<AdminProvider>()
        ..loadAnalytics()
        ..loadPackages();
    }
  }

  Future<void> _openAddProvider() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddProviderScreen()),
    );
    if (result == true && mounted) {
      context.read<AdminProvider>()
        ..loadAnalytics()
        ..loadProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = context.watch<AdminProvider>();
    final stats = admin.analytics;

    return RefreshIndicator(
      onRefresh: () => admin.loadAnalytics(),
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.profile?.displayName ?? 'Admin'} 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Platform Overview',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (admin.analyticsLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  label: 'Total Providers',
                  value: stats != null ? '${stats['total_providers'] ?? 0}' : '—',
                  icon: Icons.people_alt_rounded,
                  color: AppTheme.primary,
                  loading: admin.analyticsLoading,
                ),
                _StatCard(
                  label: 'Active Groups',
                  value: stats != null ? '${stats['active_groups'] ?? 0}' : '—',
                  icon: Icons.group_work_rounded,
                  color: AppTheme.accent,
                  loading: admin.analyticsLoading,
                ),
                _StatCard(
                  label: 'Total Members',
                  value: stats != null ? _fmt(stats['total_members'] ?? 0) : '—',
                  icon: Icons.person_rounded,
                  color: AppTheme.success,
                  loading: admin.analyticsLoading,
                ),
                _StatCard(
                  label: 'Monthly AUM',
                  value: stats != null ? '₹${_fmt(stats['monthly_aum'] ?? 0)}' : '—',
                  icon: Icons.account_balance_rounded,
                  color: AppTheme.gold,
                  loading: admin.analyticsLoading,
                ),
              ],
            ),

            if (admin.analyticsError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(admin.analyticsError!,
                          style: const TextStyle(color: AppTheme.warning, fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => admin.loadAnalytics(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Subscription plans summary
            if (stats != null && stats['plans'] != null) ...[
              const Text('Subscription Plans',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...(stats['plans'] as List).map((plan) => _PlanRow(plan: plan as Map<String, dynamic>)),
              const SizedBox(height: 24),
            ],

            // Quick Actions
            const Text('Quick Actions',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _QuickAction(
              icon: Icons.add_circle_rounded,
              title: 'Create Package',
              subtitle: 'Define a new chit template',
              color: AppTheme.primary,
              onTap: _openCreatePackage,
            ),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.person_add_rounded,
              title: 'Add Provider',
              subtitle: 'Onboard a new chit agent',
              color: AppTheme.accent,
              onTap: _openAddProvider,
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(dynamic v) {
    final n = (v as num).toDouble();
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool loading;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              loading
                  ? SizedBox(
                      width: 40,
                      height: 22,
                      child: LinearProgressIndicator(
                        backgroundColor: color.withOpacity(0.1),
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  : Text(value,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _PlanRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(plan['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${plan['subscribers'] ?? 0} subscribers',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 12),
          Text('₹${plan['price'] ?? 0}/mo',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

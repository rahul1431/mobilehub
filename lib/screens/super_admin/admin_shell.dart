import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/packages_tab.dart';
import 'tabs/providers_tab.dart';
import 'tabs/admin_reports_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _tabs = const [
    AdminDashboardTab(),
    PackagesTab(),
    ProvidersTab(),
    AdminReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apna Saving',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Super Admin • ${profile?.displayName ?? ''}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: _tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded),      label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded),    label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded),     label: 'Providers'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),      label: 'Reports'),
        ],
      ),
    );
  }
}

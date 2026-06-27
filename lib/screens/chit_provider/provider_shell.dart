import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'tabs/provider_dashboard_tab.dart';
import 'tabs/groups_tab.dart';
import 'tabs/members_tab.dart';
import 'tabs/calculator_tab.dart';
import 'tabs/chit_builder_tab.dart';
import 'collections/collections_screen.dart';

class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _index = 0;

  final _tabs = const [
    ProviderDashboardTab(),
    GroupsTab(),
    MembersTab(),
    CalculatorTab(),
    ChitBuilderTab(),
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
              'Agent • ${profile?.displayName ?? ''}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.textMuted),
            tooltip: 'Collections',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CollectionsScreen()),
            ),
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.group_work_rounded),     label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded),         label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_rounded),      label: 'Calculator'),
          BottomNavigationBarItem(icon: Icon(Icons.brush_rounded),          label: 'Builder'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import 'tabs/member_dashboard_tab.dart';
import 'tabs/passbook_tab.dart';
import 'tabs/my_groups_tab.dart';
import 'tabs/payments_tab.dart';
import 'tabs/profile_tab.dart';

class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  int _index = 0;

  static const _tabs = [
    MemberDashboardTab(),
    PassbookTab(),
    MyGroupsTab(),
    PaymentsTab(),
    ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load dashboard data when shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadDashboard();
    });
  }

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
              profile?.displayName ?? 'Member',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),        label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded),   label: 'Passbook'),
          BottomNavigationBarItem(icon: Icon(Icons.group_work_rounded),  label: 'My Chits'),
          BottomNavigationBarItem(icon: Icon(Icons.payment_rounded),     label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded),      label: 'Profile'),
        ],
      ),
    );
  }
}

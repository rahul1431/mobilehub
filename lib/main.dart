import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/trade_screen.dart';
import 'services/notification_service.dart';
import 'services/auto_trade_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService.initialize();

  final tradeService = AutoTradeService();
  await tradeService.init();

  runApp(
    ChangeNotifierProvider<AutoTradeService>.value(
      value: tradeService,
      child: const AlphaHubApp(),
    ),
  );
}

class AlphaHubApp extends StatelessWidget {
  const AlphaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpha Hub Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    InsightsScreen(),
    TradeScreen(),
    NewsScreen(),
    LedgerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppTheme.bgMain,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          items: [
            const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'HUB'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.analytics_rounded), label: 'SIGNALS'),
            BottomNavigationBarItem(
              icon: Consumer<AutoTradeService>(
                builder: (_, svc, __) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.smart_toy_rounded),
                    if (svc.isRunning)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.success,
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.success.withOpacity(0.6),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              label: 'TRADE',
            ),
            const BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_rounded), label: 'NEWS'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'LEDGER'),
            const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}

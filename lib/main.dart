import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/provider_state.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.initialize();
  LocalNotificationService.initialize();
  runApp(const ApnaSavingApp());
}

class ApnaSavingApp extends StatefulWidget {
  const ApnaSavingApp({super.key});

  @override
  State<ApnaSavingApp> createState() => _ApnaSavingAppState();
}

class _ApnaSavingAppState extends State<ApnaSavingApp> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..checkAuthStatus();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
        ChangeNotifierProvider<ProviderState>(create: (_) => ProviderState()),
      ],
      child: MaterialApp.router(
        title: 'Apna Saving',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.build(_authProvider),
      ),
    );
  }
}

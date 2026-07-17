import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/app_theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/member_provider.dart';
import 'providers/provider_state.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive offline cache
  await Hive.initFlutter();
  await Hive.openBox<String>('passbook_cache');
  await Hive.openBox<String>('groups_cache');

  ApiClient.initialize();
  LocalNotificationService.initialize();

  // Firebase — requires google-services.json (Android) and GoogleService-Info.plist (iOS)
  // If not configured, Firebase init will fail gracefully
  try {
    await Firebase.initializeApp();
    await FcmService.initialize();
  } catch (_) {
    // Firebase not configured yet — push notifications disabled until setup
  }

  // Global error boundary — render a minimal error card instead of crashing
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: AppTheme.bgMain,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              details.exceptionAsString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ]),
        ),
      ),
    );
  };

  runApp(const ApnaSavingApp());
}

class ApnaSavingApp extends StatefulWidget {
  const ApnaSavingApp({super.key});

  @override
  State<ApnaSavingApp> createState() => _ApnaSavingAppState();
}

class _ApnaSavingAppState extends State<ApnaSavingApp> {
  late final AuthProvider _authProvider;
  late final LocaleProvider _localeProvider;

  @override
  void initState() {
    super.initState();
    _authProvider  = AuthProvider()..checkAuthStatus();
    _localeProvider = LocaleProvider();
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
        ChangeNotifierProvider<LocaleProvider>.value(value: _localeProvider),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
        ChangeNotifierProvider<ProviderState>(create: (_) => ProviderState()),
        ChangeNotifierProvider<MemberProvider>(create: (_) => MemberProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (_, localeProvider, __) => MaterialApp.router(
          title: 'Apna Saving',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: localeProvider.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.build(_authProvider),
        ),
      ),
    );
  }
}

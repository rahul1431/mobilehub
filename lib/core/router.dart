import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/otp_verify_screen.dart';
import '../screens/super_admin/admin_shell.dart';
import '../screens/chit_provider/provider_shell.dart';
import '../screens/chit_member/member_shell.dart';

class AppRouter {
  static GoRouter build(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;

        if (auth.state == AuthState.initial || auth.state == AuthState.loading) {
          return loc == '/splash' ? null : '/splash';
        }

        if (auth.state == AuthState.unauthenticated) {
          if (loc == '/login' || loc == '/otp') return null;
          return '/login';
        }

        // authenticated
        if (loc == '/splash' || loc == '/login' || loc == '/otp') {
          final role = auth.profile?.role;
          if (role == 'super_admin')   return '/admin';
          if (role == 'chit_provider') return '/provider';
          return '/member';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',  builder: (_, __) => const PhoneLoginScreen()),
        GoRoute(
          path: '/otp',
          builder: (_, state) => OtpVerifyScreen(phone: state.extra as String),
        ),
        GoRoute(path: '/admin',    builder: (_, __) => const AdminShell()),
        GoRoute(path: '/provider', builder: (_, __) => const ProviderShell()),
        GoRoute(path: '/member',   builder: (_, __) => const MemberShell()),
      ],
    );
  }
}

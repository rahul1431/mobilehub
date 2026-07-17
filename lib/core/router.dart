import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/otp_verify_screen.dart';
import '../screens/super_admin/admin_shell.dart';
import '../screens/chit_provider/provider_shell.dart';
import '../screens/chit_member/member_shell.dart';
import '../screens/onboarding/kyc_intro_screen.dart';
import '../screens/onboarding/aadhaar_verify_screen.dart';
import '../screens/onboarding/pan_verify_screen.dart';
import '../screens/onboarding/agreement_sign_screen.dart';
import '../screens/chit_member/documents/documents_screen.dart';
import '../screens/chit_member/referrals/referrals_screen.dart';
import '../screens/chit_member/auction/auction_screen.dart';
import '../screens/chit_member/auction/lottery_result_screen.dart';

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

        // KYC onboarding flow
        GoRoute(path: '/kyc',           builder: (_, __) => const KycIntroScreen()),
        GoRoute(path: '/kyc/aadhaar',   builder: (_, __) => const AadhaarVerifyScreen()),
        GoRoute(path: '/kyc/pan',       builder: (_, __) => const PanVerifyScreen()),
        GoRoute(
          path: '/kyc/agreement',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return AgreementSignScreen(
              esignUrl:  extra?['esign_url'] as String? ?? '',
              groupName: extra?['group_name'] as String?,
            );
          },
        ),

        // Member sub-screens (pushed on top of shell)
        GoRoute(path: '/member/documents',  builder: (_, __) => const DocumentsScreen()),
        GoRoute(path: '/member/referrals',  builder: (_, __) => const ReferralsScreen()),
        GoRoute(
          path: '/member/auction',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>;
            return AuctionScreen(
              cycleId:     extra['cycle_id'] as int,
              totalPot:    extra['total_pot'] as double,
              groupName:   extra['group_name'] as String,
              cycleNumber: extra['cycle_number'] as int,
            );
          },
        ),
        GoRoute(
          path: '/member/lottery-result',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>;
            return LotteryResultScreen(
              winnerName:        extra['winner_name'] as String,
              totalPot:          extra['total_pot'] as double,
              groupName:         extra['group_name'] as String,
              cycleNumber:       extra['cycle_number'] as int,
              winningBid:        extra['winning_bid'] as double?,
              dividendPerMember: extra['dividend_per_member'] as double?,
              isWinner:          extra['is_winner'] as bool? ?? false,
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class KycIntroScreen extends StatefulWidget {
  const KycIntroScreen({super.key});

  @override
  State<KycIntroScreen> createState() => _KycIntroScreenState();
}

class _KycIntroScreenState extends State<KycIntroScreen> {
  bool _loading = true;
  String _kycStatus = 'pending';
  List<dynamic> _docs = [];

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final res = await ApiClient.instance.get('/member/kyc/status');
      if (mounted) {
        setState(() {
          _kycStatus = res.data['kyc_status'] as String? ?? 'pending';
          _docs      = res.data['documents'] as List? ?? [];
          _loading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasDoc(String type) =>
      _docs.any((d) => d['doc_type'] == type && d['verified'] == true);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('KYC Verification',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Status banner
                _StatusBanner(status: _kycStatus),
                const SizedBox(height: 28),

                const Text('Complete Your KYC',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'KYC verification is required to participate in chit groups and receive payouts.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),

                // Steps
                GlassCard(
                  child: Column(children: [
                    _KycStep(
                      number: 1,
                      title: 'Aadhaar Verification',
                      subtitle: 'Verify via Aadhaar OTP',
                      done: _hasDoc('aadhaar'),
                      onTap: _kycStatus != 'verified' && !_hasDoc('aadhaar')
                          ? () => context.push('/kyc/aadhaar')
                          : null,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _KycStep(
                      number: 2,
                      title: 'PAN Card Verification',
                      subtitle: 'Enter your 10-digit PAN',
                      done: _hasDoc('pan'),
                      locked: !_hasDoc('aadhaar'),
                      onTap: _hasDoc('aadhaar') && !_hasDoc('pan')
                          ? () => context.push('/kyc/pan')
                          : null,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _KycStep(
                      number: 3,
                      title: 'e-Sign Agreement',
                      subtitle: 'Sign your chit group agreement',
                      done: _hasDoc('agreement'),
                      locked: !_hasDoc('aadhaar') || !_hasDoc('pan'),
                      onTap: _hasDoc('aadhaar') && _hasDoc('pan') && !_hasDoc('agreement')
                          ? () => context.push('/kyc/agreement')
                          : null,
                    ),
                  ]),
                ),

                const SizedBox(height: 24),

                if (_kycStatus == 'verified') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/member'),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Go to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) context.go('/login');
                    },
                    child: const Text('Logout', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ),
              ]),
            ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, text) = switch (status) {
      'verified' => (AppTheme.success, Icons.verified_rounded, 'KYC Verified'),
      'rejected' => (AppTheme.error,   Icons.cancel_rounded,   'KYC Rejected — please retry'),
      _          => (AppTheme.warning,  Icons.pending_rounded,  'KYC Pending'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _KycStep extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final bool done;
  final bool locked;
  final VoidCallback? onTap;

  const _KycStep({
    required this.number,
    required this.title,
    required this.subtitle,
    this.done = false,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppTheme.success : locked ? AppTheme.textMuted : AppTheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Center(
              child: done
                  ? Icon(Icons.check_rounded, color: AppTheme.success, size: 18)
                  : locked
                      ? Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted, size: 16)
                      : Text('$number', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
                color: locked ? AppTheme.textMuted : Colors.white,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ])),
          if (onTap != null)
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primary, size: 14),
          if (done)
            const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
        ]),
      ),
    );
  }
}

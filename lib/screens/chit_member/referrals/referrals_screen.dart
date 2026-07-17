import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../core/api_client.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_card.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  bool _loading = true;
  String? _code;
  int _count = 0;
  List<dynamic> _referrals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/member/referrals');
      if (mounted) {
        setState(() {
          _code      = res.data['referral_code'] as String?;
          _count     = res.data['referrals_count'] as int? ?? 0;
          _referrals = res.data['referrals'] as List? ?? [];
          _loading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _share() {
    if (_code == null) return;
    Share.share(
      'Join me on Apna Saving — India\'s smartest chit fund app!\n'
      'Use my referral code: $_code\n'
      'Download: https://apnasaving.app',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthProvider>().profile;

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('My Referrals',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.primary),
            onPressed: _share,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Referral code hero
                  GlassCard(
                    child: Column(children: [
                      const Icon(Icons.card_giftcard_rounded,
                          color: AppTheme.gold, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _code ?? profile?.referralCode ?? '—',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 28, fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share your code and earn when friends join',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share Referral Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Count stat
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.people_rounded, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text('$_count friend${_count == 1 ? '' : 's'} joined',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),

                  if (_referrals.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Your Referrals',
                        style: TextStyle(color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._referrals.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ReferralRow(referral: r as Map<String, dynamic>),
                    )),
                  ] else ...[
                    const SizedBox(height: 40),
                    const Center(child: Column(children: [
                      Icon(Icons.people_outline_rounded,
                          color: AppTheme.textMuted, size: 56),
                      SizedBox(height: 12),
                      Text('No referrals yet',
                          style: TextStyle(color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Share your code to get started',
                          style: TextStyle(color: AppTheme.textMuted)),
                    ])),
                  ],
                ],
              ),
            ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final Map<String, dynamic> referral;
  const _ReferralRow({required this.referral});

  @override
  Widget build(BuildContext context) {
    final kyc = referral['kyc_status'] as String? ?? 'pending';
    final kycColor = kyc == 'verified' ? AppTheme.success : AppTheme.warning;

    return GlassCard(
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primary.withOpacity(0.15),
          child: Text(
            (referral['name'] as String? ?? '?')[0].toUpperCase(),
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(referral['name'] as String? ?? 'Member',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(referral['joined_at'] as String? ?? '',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kycColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            kyc == 'verified' ? 'KYC Done' : 'KYC Pending',
            style: TextStyle(color: kycColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }
}

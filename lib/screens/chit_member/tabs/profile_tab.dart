import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(
                  (profile?.displayName.isNotEmpty == true
                      ? profile!.displayName[0].toUpperCase()
                      : '?'),
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(profile?.displayName ?? 'Member',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(profile?.phone ?? '',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            ]),
          ),

          const SizedBox(height: 24),

          // KYC status card
          GlassCard(
            child: Row(
              children: [
                Icon(
                  profile?.isKycDone == true
                      ? Icons.verified_user_rounded
                      : Icons.pending_actions_rounded,
                  color: profile?.isKycDone == true ? AppTheme.success : AppTheme.warning,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('KYC Status',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  Text(
                    profile?.isKycDone == true ? 'Verified' : 'Pending Verification',
                    style: TextStyle(
                      color: profile?.isKycDone == true ? AppTheme.success : AppTheme.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                const Spacer(),
                if (profile?.isKycDone != true)
                  TextButton(
                    onPressed: () => context.push('/kyc'),
                    child: const Text('Complete', style: TextStyle(color: AppTheme.primary)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Referral code card
          if (profile?.referralCode != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Referral Code',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        profile!.referralCode!,
                        style: const TextStyle(
                            color: AppTheme.gold, fontSize: 22,
                            fontWeight: FontWeight.bold, letterSpacing: 3),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: AppTheme.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: profile.referralCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Referral code copied!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Share this code to earn rewards',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Menu items
          _menuItem(
            context,
            icon: Icons.description_rounded,
            label: 'My Documents',
            subtitle: 'KYC & signed agreements',
            onTap: () => context.push('/member/documents'),
          ),
          _menuItem(
            context,
            icon: Icons.people_outline_rounded,
            label: 'My Referrals',
            subtitle: 'Track who you referred',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Referrals — coming in Phase 9.')),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            subtitle: 'Contact your chit provider',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: const Text('Logout', style: TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Center(
            child: Text('Apna Saving v1.0.0',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ]),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

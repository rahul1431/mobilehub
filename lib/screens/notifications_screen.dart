import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final _notifications = [
    _Notif(
      icon: Icons.check_circle_outline,
      title: 'No EMI Due',
      body: 'Your Gold Loan 00878/MH/PI/000286 has no pending EMI. You\'re all clear!',
      time: '1 hour ago',
      color: AppColors.success,
      isRead: false,
    ),
    _Notif(
      icon: Icons.trending_up,
      title: 'Gold Rate Alert',
      body: '22K Gold rate increased by 0.85% today. Good time to check your loan value!',
      time: '5 hours ago',
      color: AppColors.gold,
      isRead: false,
    ),
    _Notif(
      icon: Icons.check_circle,
      title: 'Loan Disbursed',
      body: '₹1,94,000 disbursed for Loan 00878/MH/PI/000286 (Muthoot High Value Plus).',
      time: '21 Mar 2022',
      color: AppColors.success,
      isRead: true,
    ),
    _Notif(
      icon: Icons.local_offer,
      title: 'Special Offer',
      body: 'Get 0.5% lower interest rate on Gold Loans this festive season!',
      time: '3 days ago',
      color: AppColors.primary,
      isRead: true,
    ),
    _Notif(
      icon: Icons.verified_user,
      title: 'KYC Verified',
      body: 'Your KYC verification is complete. You can now access all services.',
      time: '1 week ago',
      color: AppColors.success,
      isRead: true,
    ),
    _Notif(
      icon: Icons.diamond_outlined,
      title: 'Gold Appraisal Complete',
      body: '7 gold items appraised. Net weight: 56.3g. Eligible amount: ₹1,95,924.',
      time: '21 Mar 2022',
      color: AppColors.gold,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _NotifCard(notif: _notifications[i]),
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final bool isRead;
  const _Notif({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    required this.isRead,
  });
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead ? AppColors.divider : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notif.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notif.icon, color: notif.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notif.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: notif.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: AppColors.textDark,
                        )),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notif.body,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        height: 1.4)),
                const SizedBox(height: 6),
                Text(notif.time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

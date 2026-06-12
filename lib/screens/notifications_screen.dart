import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final _notifications = [
    _Notif(
      icon: Icons.payment,
      title: 'EMI Due Reminder',
      body: 'Your Gold Loan GL-2024-001 EMI of ₹5,250 is due in 3 days.',
      time: '2 hours ago',
      color: AppColors.warning,
      isRead: false,
    ),
    _Notif(
      icon: Icons.trending_up,
      title: 'Gold Rate Alert',
      body: '22K Gold rate increased by 0.85% today. Good time to apply for a loan!',
      time: '5 hours ago',
      color: AppColors.gold,
      isRead: false,
    ),
    _Notif(
      icon: Icons.check_circle,
      title: 'Payment Successful',
      body: 'Your EMI payment of ₹5,000 for GL-2024-001 was successful.',
      time: '2 days ago',
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
      icon: Icons.account_balance_wallet,
      title: 'Loan Disbursed',
      body: 'Gold Loan of ₹25,000 has been disbursed to your account.',
      time: '1 week ago',
      color: AppColors.primary,
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

import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fmt = NumberFormat('#,##,###', 'en_IN');

  final _banners = const [
    _BannerData(
      title: 'Apply Gold Loan',
      subtitle: 'Get up to ₹1.5 Crore\nInstantly at your doorstep',
      color1: Color(0xFFB71C1C),
      color2: Color(0xFF7F0000),
      icon: Icons.diamond_outlined,
    ),
    _BannerData(
      title: 'Digital Gold',
      subtitle: 'Buy 24K Pure Gold\nStarting from ₹1',
      color1: Color(0xFFFF8F00),
      color2: Color(0xFFE65100),
      icon: Icons.bar_chart,
    ),
    _BannerData(
      title: 'Personal Loan',
      subtitle: 'Quick disbursal\nMinimal documentation',
      color1: Color(0xFF1565C0),
      color2: Color(0xFF0D47A1),
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  final _quickActions = const [
    _QuickAction(icon: Icons.add_card, label: 'Apply\nLoan', route: '/apply-loan'),
    _QuickAction(icon: Icons.payment, label: 'Pay\nEMI', route: '/pay-emi'),
    _QuickAction(icon: Icons.search, label: 'Loan\nStatus', route: '/loan-status'),
    _QuickAction(icon: Icons.calculate_outlined, label: 'EMI\nCalc', route: '/emi-calculator'),
  ];

  final _services = const [
    _ServiceData(icon: Icons.diamond, label: 'Gold Loan', route: '/gold-loan', color: Color(0xFFFFF3E0)),
    _ServiceData(icon: Icons.person, label: 'Personal Loan', route: '/personal-loan', color: Color(0xFFE3F2FD)),
    _ServiceData(icon: Icons.bar_chart, label: 'Digital Gold', route: '/digital-gold', color: Color(0xFFFFF8E1)),
    _ServiceData(icon: Icons.send, label: 'Money Transfer', route: '/money-transfer', color: Color(0xFFE8F5E9)),
    _ServiceData(icon: Icons.currency_exchange, label: 'Forex', route: '/forex', color: Color(0xFFF3E5F5)),
    _ServiceData(icon: Icons.shield_outlined, label: 'Insurance', route: '/insurance', color: Color(0xFFE0F7FA)),
    _ServiceData(icon: Icons.trending_up, label: 'Mutual Funds', route: '/mutual-funds', color: Color(0xFFFCE4EC)),
    _ServiceData(icon: Icons.receipt_long, label: 'Bill Pay', route: '/bill-pay', color: Color(0xFFE8EAF6)),
    _ServiceData(icon: Icons.location_on, label: 'Find Branch', route: '/branches', color: Color(0xFFF1F8E9)),
  ];

  @override
  Widget build(BuildContext context) {
    final rate = MockData.goldRate;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hello, Ranjith Rathod 👋',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Customer ID: 00878000011347',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _iconBtn(Icons.notifications_outlined,
                                    () => Navigator.pushNamed(context, '/notifications')),
                                const SizedBox(width: 8),
                                _iconBtn(Icons.account_circle_outlined,
                                    () => Navigator.pushNamed(context, '/profile')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Gold rate pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond,
                                  size: 14, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Text(
                                '22K Gold: ₹${fmt.format(rate.rate22k)}/g',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                rate.isUp
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 12,
                                color: rate.isUp
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                              Text(
                                '${rate.change}%',
                                style: TextStyle(
                                  color: rate.isUp
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: const Text('iMuthoot'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, '/notifications'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Promo Banners
                _BannerCarousel(banners: _banners),
                const SizedBox(height: 20),
                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _quickActions
                            .map((a) => _QuickActionBtn(
                                  action: a,
                                  onTap: () => Navigator.pushNamed(
                                      context, a.route),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Active Loans
                if (MockData.loans.isNotEmpty) ...[
                  _sectionHeader('Active Loans', 'View All',
                      () => Navigator.pushNamed(context, '/loan-status')),
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: MockData.loans.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/loan-status'),
                        child: _LoanCard(loan: MockData.loans[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // All Services
                _sectionHeader('Our Services', '', null),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (_, i) => _ServiceCard(
                      data: _services[i],
                      onTap: () =>
                          Navigator.pushNamed(context, _services[i].route),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Recent Transactions
                _sectionHeader('Recent Transactions', 'View All',
                    () => Navigator.pushNamed(context, '/transactions')),
                ...MockData.transactions
                    .take(3)
                    .map((t) => _TransactionTile(txn: t)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<_BannerData> banners;
  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;
      final next = (_current + 1) % widget.banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _PromoBanner(data: widget.banners[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
  });
}

class _PromoBanner extends StatelessWidget {
  final _BannerData data;
  const _PromoBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.color1, data.color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Apply Now →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(data.icon, size: 70, color: Colors.white.withOpacity(0.2)),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction(
      {required this.icon, required this.label, required this.route});
}

class _QuickActionBtn extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Icon(action.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final GoldLoan loan;
  _LoanCard({required this.loan});
  final fmt = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        loan.dueDate.difference(DateTime.now()).inDays;
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.loanId,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loan.status,
                  style: const TextStyle(
                      color: Colors.greenAccent, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${fmt.format(loan.amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Outstanding: ₹${fmt.format(loan.outstandingAmount)}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const Spacer(),
          Text(
            daysLeft > 90 ? 'No EMI Due' : 'Due in $daysLeft days',
            style: const TextStyle(
                color: AppColors.gold, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _ServiceData({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceData data;
  final VoidCallback onTap;
  const _ServiceCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction txn;
  _TransactionTile({required this.txn});
  final fmt = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: txn.isCredit
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              txn.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: txn.isCredit ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${txn.isCredit ? '+' : '-'}₹${fmt.format(txn.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      txn.isCredit ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM').format(txn.date),
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/models.dart';

class GoldLoanScreen extends StatelessWidget {
  const GoldLoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,###', 'en_IN');
    final rate = MockData.goldRate;

    return Scaffold(
      appBar: AppBar(title: const Text('Gold Loan')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold Rate Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Gold Rate',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _GoldRateItem(
                          karat: '22K',
                          rate: '₹${fmt.format(rate.rate22k)}/g'),
                      const SizedBox(width: 32),
                      _GoldRateItem(
                          karat: '24K',
                          rate: '₹${fmt.format(rate.rate24k)}/g'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        rate.isUp ? Icons.trending_up : Icons.trending_down,
                        color: rate.isUp ? Colors.greenAccent : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rate.change}% from yesterday',
                        style: TextStyle(
                          color: rate.isUp ? Colors.greenAccent : Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Apply CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/apply-loan'),
                icon: const Icon(Icons.diamond_outlined),
                label: const Text('Apply for Gold Loan'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OutlineBtn(
                    icon: Icons.calculate_outlined,
                    label: 'EMI Calculator',
                    onTap: () => Navigator.pushNamed(context, '/emi-calculator'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutlineBtn(
                    icon: Icons.search,
                    label: 'Loan Status',
                    onTap: () => Navigator.pushNamed(context, '/loan-status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Loan Types
            const Text(
              'Loan Types',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ..._loanTypes.map((lt) => _LoanTypeCard(data: lt)),

            const SizedBox(height: 24),
            const Text(
              'My Active Loans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...MockData.loans.map((loan) => _ActiveLoanCard(loan: loan)),
          ],
        ),
      ),
    );
  }

  static final _loanTypes = [
    _LoanType('Regular Gold Loan', 'Up to ₹1.5 Cr • 12 months', Icons.diamond,
        'Interest from 11% p.a.'),
    _LoanType('Bullet Loan', 'Pay at end of tenure', Icons.arrow_forward,
        'No monthly EMI burden'),
    _LoanType('Overdraft Loan', 'Flexible withdrawals', Icons.account_balance,
        'Pay interest only on usage'),
  ];
}

class _GoldRateItem extends StatelessWidget {
  final String karat;
  final String rate;
  const _GoldRateItem({required this.karat, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(karat,
            style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(rate,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _LoanType {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  const _LoanType(this.title, this.subtitle, this.icon, this.badge);
}

class _LoanTypeCard extends StatelessWidget {
  final _LoanType data;
  const _LoanTypeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black08, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(data.subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                Text(data.badge,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.primary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textGrey),
        ],
      ),
    );
  }
}

class _ActiveLoanCard extends StatelessWidget {
  final GoldLoan loan;
  _ActiveLoanCard({required this.loan});
  final fmt = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    final progress = (loan.amount - (loan.outstandingAmount - loan.amount)) /
        loan.amount;
    final daysLeft = loan.dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loan.loanId,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(loan.status,
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _loanStat('Loan Amount',
                  '₹${fmt.format(loan.amount)}'),
              const SizedBox(width: 24),
              _loanStat('Outstanding',
                  '₹${fmt.format(loan.outstandingAmount)}'),
              const SizedBox(width: 24),
              _loanStat('Gold Weight', '${loan.goldWeight}g'),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due in $daysLeft days',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.warning)),
              GestureDetector(
                onTap: () {},
                child: const Text('Pay EMI →',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
      ],
    );
  }
}

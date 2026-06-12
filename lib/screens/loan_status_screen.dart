import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/models.dart';

class LoanStatusScreen extends StatelessWidget {
  const LoanStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Status')),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...MockData.loans.map((loan) => _LoanDetailCard(loan: loan)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Track Application',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                _TrackStep('Application Submitted', true, true),
                _TrackStep('Document Verification', true, true),
                _TrackStep('Gold Appraisal', true, false),
                _TrackStep('Loan Sanctioned', false, false),
                _TrackStep('Amount Disbursed', false, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanDetailCard extends StatelessWidget {
  final GoldLoan loan;
  _LoanDetailCard({required this.loan});
  final fmt = NumberFormat('#,##,###', 'en_IN');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loan.loanId,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textDark)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const Divider(height: 20),
          _row('Scheme', loan.scheme),
          _row('Loan Amount', '₹${fmt.format(loan.amount)}'),
          _row('Eligible Amount', '₹${fmt.format(loan.eligibleAmount)}'),
          _row('Outstanding', '₹${fmt.format(loan.outstandingAmount)}'),
          _row('Net Gold Weight', '${loan.netWeight}g'),
          _row('Gross Weight', '${loan.grossWeight}g'),
          _row('Interest Rate', '${loan.interestRate}% p.a.'),
          _row('Eff. Annual Rate', '${loan.annualizedRate}%'),
          _row('Sanction Date', DateFormat('dd MMM yyyy').format(loan.sanctionDate)),
          _row('Due Date', DateFormat('dd MMM yyyy').format(loan.dueDate)),
          _row('Payment Mode', loan.paymentMode),
          const SizedBox(height: 14),
          const Text('Pledged Gold Items',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
          const SizedBox(height: 8),
          ...loan.ornaments.map((o) => _ornamentRow(o)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                SizedBox(width: 8),
                Text('No EMI Due', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _ornamentRow(GoldOrnament o) {
    final fmt = NumberFormat('#,##,###', 'en_IN');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.diamond_outlined, size: 14, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(child: Text('${o.name} (${o.count})', style: const TextStyle(fontSize: 12, color: AppColors.textDark))),
          Text('${o.netWeight}g', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(width: 12),
          Text('₹${fmt.format(o.eligibleAmount.round())}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _TrackStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isActive;
  const _TrackStep(this.label, this.isDone, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success
                    : isActive
                        ? AppColors.gold
                        : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone
                    ? Icons.check
                    : isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (label != 'Amount Disbursed')
              Container(
                  width: 2, height: 32, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isActive
                ? AppColors.textDark
                : AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

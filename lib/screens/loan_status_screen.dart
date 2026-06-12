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
          _row('Loan Amount', '₹${fmt.format(loan.amount)}'),
          _row('Outstanding', '₹${fmt.format(loan.outstandingAmount)}'),
          _row('Gold Weight', '${loan.goldWeight}g'),
          _row('Interest Rate', '${loan.interestRate}% p.a.'),
          _row('Due Date',
              DateFormat('dd MMM yyyy').format(loan.dueDate)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              child: const Text('Pay EMI'),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textGrey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _loanAmount = 100000;
  double _interestRate = 12;
  double _tenure = 12;
  final fmt = NumberFormat('#,##,###', 'en_IN');

  double get _emi {
    final r = _interestRate / 12 / 100;
    final n = _tenure;
    if (r == 0) return _loanAmount / n;
    return _loanAmount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  double get _totalPayable => _emi * _tenure;
  double get _totalInterest => _totalPayable - _loanAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Calculator')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Monthly EMI',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${fmt.format(_emi.round())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultStat(
                        label: 'Principal',
                        value: '₹${fmt.format(_loanAmount.round())}',
                      ),
                      _ResultStat(
                        label: 'Interest',
                        value: '₹${fmt.format(_totalInterest.round())}',
                      ),
                      _ResultStat(
                        label: 'Total Payable',
                        value: '₹${fmt.format(_totalPayable.round())}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SliderField(
                      label: 'Loan Amount',
                      value: _loanAmount,
                      min: 10000,
                      max: 5000000,
                      divisions: 490,
                      display: '₹${fmt.format(_loanAmount.round())}',
                      onChanged: (v) => setState(() => _loanAmount = v),
                    ),
                    const SizedBox(height: 20),
                    _SliderField(
                      label: 'Interest Rate',
                      value: _interestRate,
                      min: 8,
                      max: 24,
                      divisions: 160,
                      display: '${_interestRate.toStringAsFixed(1)}% p.a.',
                      onChanged: (v) => setState(() => _interestRate = v),
                    ),
                    const SizedBox(height: 20),
                    _SliderField(
                      label: 'Tenure',
                      value: _tenure,
                      min: 1,
                      max: 60,
                      divisions: 59,
                      display: '${_tenure.round()} months',
                      onChanged: (v) => setState(() => _tenure = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Breakdown',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 16),
                    _BreakdownRow(
                      label: 'Principal Amount',
                      value: '₹${fmt.format(_loanAmount.round())}',
                      color: AppColors.primary,
                      fraction: _loanAmount / _totalPayable,
                    ),
                    const SizedBox(height: 10),
                    _BreakdownRow(
                      label: 'Total Interest',
                      value: '₹${fmt.format(_totalInterest.round())}',
                      color: AppColors.gold,
                      fraction: _totalInterest / _totalPayable,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Payable',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                                fontSize: 14)),
                        Text('₹${fmt.format(_totalPayable.round())}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/apply-loan'),
                child: const Text('Apply for Loan'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(display,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double fraction;
  const _BreakdownRow(
      {required this.label,
      required this.value,
      required this.color,
      required this.fraction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textGrey)),
              ],
            ),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: fraction.isNaN ? 0 : fraction.clamp(0.0, 1.0),
          backgroundColor: AppColors.divider,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  final _monthly    = TextEditingController(text: '5000');
  final _duration   = TextEditingController(text: '20');
  final _members    = TextEditingController(text: '20');
  final _commission = TextEditingController(text: '5');

  double get monthly    => double.tryParse(_monthly.text)    ?? 0;
  double get duration   => double.tryParse(_duration.text)   ?? 0;
  double get members    => double.tryParse(_members.text)    ?? 0;
  double get commission => double.tryParse(_commission.text) ?? 0;

  double get totalPot         => monthly * members;
  double get commissionAmt    => totalPot * commission / 100;
  double get memberNetPayout  => totalPot - commissionAmt;
  double get totalCommission  => commissionAmt * duration;
  double get totalPaidByMember=> monthly * duration;

  @override
  void dispose() {
    _monthly.dispose(); _duration.dispose();
    _members.dispose(); _commission.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Chit Calculator',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Model your chit group financials before creating',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        const SizedBox(height: 20),

        // Inputs
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(children: [
            _input(_monthly, 'Monthly Amount (₹)', '5000'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _input(_duration, 'Duration (Months)', '20')),
              const SizedBox(width: 12),
              Expanded(child: _input(_members, 'Members', '20')),
            ]),
            const SizedBox(height: 12),
            _input(_commission, 'Commission (%)', '5.0', decimal: true),
          ]),
        ),
        const SizedBox(height: 20),

        // Results
        if (totalPot > 0) ...[
          const Text('Projected Financials',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _resultCard('Per Cycle', [
            _r('Total Pot', '₹${_f(totalPot)}', highlight: true),
            _r('Your Commission', '₹${_f(commissionAmt)}', color: AppTheme.gold),
            _r('Member Net Payout', '₹${_f(memberNetPayout)}'),
          ]),
          const SizedBox(height: 12),
          _resultCard('Full Duration (${duration.toInt()} months)', [
            _r('Total Collected', '₹${_f(totalPot * duration)}', highlight: true),
            _r('Total Commission', '₹${_f(totalCommission)}', color: AppTheme.gold),
            _r('Each Member Pays', '₹${_f(totalPaidByMember)}'),
          ]),
          const SizedBox(height: 12),
          _resultCard('Member Perspective', [
            _r('Total Paid Over ${duration.toInt()} months', '₹${_f(totalPaidByMember)}'),
            _r('When Win Early (Month 1)', '₹${_f(memberNetPayout - totalPaidByMember + monthly)}',
                color: AppTheme.success),
            _r('When Win Late (Last Month)', '₹${_f(memberNetPayout - totalPaidByMember)}',
                color: memberNetPayout - totalPaidByMember >= 0 ? AppTheme.success : AppTheme.error),
            _r('Net Savings (Last Month)', '₹${_f(memberNetPayout - totalPaidByMember)}'),
          ]),
          const SizedBox(height: 20),
          // Member position chart
          const Text('Net Return by Position',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _PositionChart(
            duration: duration.toInt(),
            monthly: monthly,
            memberNetPayout: memberNetPayout,
          ),
        ],
      ]),
    );
  }

  Widget _input(TextEditingController ctrl, String label, String hint, {bool decimal = false}) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'))],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _resultCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...rows,
      ]),
    );
  }

  Widget _r(String label, String value, {bool highlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Text(value, style: TextStyle(
          color: color ?? (highlight ? Colors.white : Colors.white70),
          fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          fontSize: highlight ? 15 : 13,
        )),
      ]),
    );
  }

  String _f(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(2)}Cr';
    if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000)     return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }
}

class _PositionChart extends StatelessWidget {
  final int duration;
  final double monthly;
  final double memberNetPayout;

  const _PositionChart({required this.duration, required this.monthly, required this.memberNetPayout});

  @override
  Widget build(BuildContext context) {
    if (duration <= 0) return const SizedBox.shrink();
    final returns = List.generate(duration, (i) {
      final monthWon = i + 1;
      final totalPaid = monthly * monthWon;
      return memberNetPayout - totalPaid;
    });
    final maxAbs = returns.map((v) => v.abs()).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: [
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(duration, (i) {
              final v = returns[i];
              final frac = maxAbs > 0 ? (v / maxAbs) : 0.0;
              final positive = v >= 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: frac.abs().clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: positive ? AppTheme.success.withOpacity(0.7) : AppTheme.error.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Month 1\n(Win Early)', style: TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
          const Text('Break-even', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          Text('Month $duration\n(Win Late)', style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 4), color: AppTheme.success.withOpacity(0.7)),
          const Text('Net gain ', style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(width: 12),
          Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 4), color: AppTheme.error.withOpacity(0.7)),
          const Text('Net loss', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ]),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/models.dart';

class DigitalGoldScreen extends StatefulWidget {
  const DigitalGoldScreen({super.key});

  @override
  State<DigitalGoldScreen> createState() => _DigitalGoldScreenState();
}

class _DigitalGoldScreenState extends State<DigitalGoldScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController(text: '1000');
  bool _byAmount = true;
  final fmt = NumberFormat('#,##,###', 'en_IN');

  double get _goldRate => MockData.goldRate.rate24k;

  double get _grams {
    final amt = double.tryParse(_amountController.text) ?? 0;
    return _byAmount ? amt / _goldRate : amt;
  }

  double get _rupees {
    final amt = double.tryParse(_amountController.text) ?? 0;
    return _byAmount ? amt : amt * _goldRate;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _transact(bool isBuy) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isBuy ? 'Confirm Purchase' : 'Confirm Sale'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow('Gold', '${_grams.toStringAsFixed(4)}g'),
            _dialogRow('Rate', '₹${fmt.format(_goldRate)}/g'),
            _dialogRow('Amount', '₹${fmt.format(_rupees.round())}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBuy
                        ? 'Purchase successful! ${_grams.toStringAsFixed(4)}g added to your vault.'
                        : 'Sale successful! ₹${fmt.format(_rupees.round())} credited.',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isBuy ? 'Confirm Buy' : 'Confirm Sell'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = MockData.goldRate;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Gold')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Rate Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF8F00), Color(0xFFE65100)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('24K Pure Gold',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      '₹${fmt.format(rate.rate24k)}/gram',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          rate.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.greenAccent,
                          size: 14,
                        ),
                        Text(
                          '${rate.change}%',
                          style: const TextStyle(
                              color: Colors.greenAccent, fontSize: 13),
                        ),
                      ],
                    ),
                    const Text('Today',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          // Portfolio summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black08,
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _VaultStat('My Gold', '1.532g'),
                _divider(),
                _VaultStat('Current Value', '₹${fmt.format((1.532 * rate.rate24k).round())}'),
                _divider(),
                _VaultStat('P&L', '+₹842', isPositive: true),
              ],
            ),
          ),

          // Buy/Sell Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black08,
                    blurRadius: 6,
                    offset: Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textGrey,
                  tabs: const [
                    Tab(text: 'Buy Gold'),
                    Tab(text: 'Sell Gold'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Toggle by amount / grams
                      Row(
                        children: [
                          _ToggleBtn(
                            label: 'By Amount (₹)',
                            isSelected: _byAmount,
                            onTap: () => setState(() => _byAmount = true),
                          ),
                          const SizedBox(width: 8),
                          _ToggleBtn(
                            label: 'By Grams (g)',
                            isSelected: !_byAmount,
                            onTap: () => setState(() => _byAmount = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'))
                        ],
                        decoration: InputDecoration(
                          prefixText: _byAmount ? '₹ ' : '',
                          suffixText: !_byAmount ? ' g' : '',
                          hintText: _byAmount ? 'Enter amount' : 'Enter grams',
                          prefixStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              fontSize: 16),
                        ),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _byAmount
                            ? 'You get: ${_grams.toStringAsFixed(4)}g'
                            : 'You pay: ₹${fmt.format(_rupees.round())}',
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      // Quick amount chips
                      Wrap(
                        spacing: 8,
                        children: [500, 1000, 2000, 5000].map((amt) {
                          return ActionChip(
                            label: Text('₹$amt'),
                            backgroundColor: AppColors.background,
                            side: const BorderSide(color: AppColors.divider),
                            onPressed: () {
                              _amountController.text = amt.toString();
                              setState(() => _byAmount = true);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: TabBarView(
                controller: _tabController,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _transact(true),
                    icon: const Icon(Icons.add),
                    label: const Text('Buy Gold'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _transact(false),
                    icon: const Icon(Icons.sell),
                    label: const Text('Sell Gold'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: AppColors.divider);
}

class _VaultStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;
  const _VaultStat(this.label, this.value, {this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPositive ? AppColors.success : AppColors.textDark)),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/chit_package_model.dart';
import '../../../providers/admin_provider.dart';

class CreatePackageScreen extends StatefulWidget {
  final ChitPackageModel? existing;
  const CreatePackageScreen({super.key, this.existing});

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _monthly;
  late final TextEditingController _duration;
  late final TextEditingController _maxMembers;
  late final TextEditingController _commission;
  bool _isActive = true;
  bool _saving = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _monthly = TextEditingController(text: e?.monthlyAmount.toStringAsFixed(0) ?? '');
    _duration = TextEditingController(text: e?.durationMonths.toString() ?? '');
    _maxMembers = TextEditingController(text: e?.maxMembers.toString() ?? '');
    _commission = TextEditingController(text: e?.commissionPct.toStringAsFixed(1) ?? '');
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _monthly.dispose();
    _duration.dispose();
    _maxMembers.dispose();
    _commission.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final body = {
      'name': _name.text.trim(),
      'monthly_amount': double.parse(_monthly.text),
      'duration_months': int.parse(_duration.text),
      'max_members': int.parse(_maxMembers.text),
      'commission_pct': double.parse(_commission.text),
      'is_active': _isActive,
    };

    final admin = context.read<AdminProvider>();
    bool ok;
    if (isEdit) {
      ok = await admin.updatePackage(widget.existing!.id, body);
    } else {
      ok = await admin.createPackage(body);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(admin.packagesError ?? 'Something went wrong'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Package' : 'New Package'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(
              controller: _name,
              label: 'Package Name',
              hint: 'e.g. Gold 10K Monthly',
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _monthly,
              label: 'Monthly Amount (₹)',
              hint: 'e.g. 5000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _field(
                  controller: _duration,
                  label: 'Duration (Months)',
                  hint: '12',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n < 2) return 'Min 2';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _field(
                  controller: _maxMembers,
                  label: 'Max Members',
                  hint: '20',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n < 2) return 'Min 2';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _field(
              controller: _commission,
              label: 'Agent Commission (%)',
              hint: 'e.g. 5.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                final n = double.tryParse(v);
                if (n == null || n < 0 || n > 30) return '0–30%';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Projected summary card
            ValueListenableBuilder(
              valueListenable: _monthly,
              builder: (_, __, ___) => ValueListenableBuilder(
                valueListenable: _maxMembers,
                builder: (_, __, ___) => ValueListenableBuilder(
                  valueListenable: _commission,
                  builder: (_, __, ___) => _buildSummaryCard(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Active', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEdit ? 'Save Changes' : 'Create Package'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final monthly = double.tryParse(_monthly.text) ?? 0;
    final members = int.tryParse(_maxMembers.text) ?? 0;
    final commission = double.tryParse(_commission.text) ?? 0;
    final totalPot = monthly * members;
    final commissionAmt = totalPot * commission / 100;
    final memberNet = totalPot - commissionAmt;

    if (totalPot == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Projected Financials',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _summaryRow('Total Pot per Cycle', '₹${_fmt(totalPot)}'),
          _summaryRow('Agent Commission', '₹${_fmt(commissionAmt)} (${commission.toStringAsFixed(1)}%)'),
          _summaryRow('Member Net Payout', '₹${_fmt(memberNet)}', highlight: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: TextStyle(
                color: highlight ? AppTheme.accent : Colors.white,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

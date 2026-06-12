import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_theme.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Step 1
  String? _loanType = 'Regular Gold Loan';
  final _amountController = TextEditingController(text: '50000');

  // Step 2
  final _nameController = TextEditingController(text: 'Pathloth Ranjith Rathod');
  final _dobController = TextEditingController(text: '01/01/1990');
  final _panController = TextEditingController();
  String? _idType = 'Aadhaar Card';

  // Step 3
  final _addressController = TextEditingController();
  String? _branch = 'MG Road, Bangalore';

  bool _loading = false;

  final _loanTypes = [
    'Regular Gold Loan',
    'Bullet Loan',
    'Overdraft Loan',
    'Personal Loan',
  ];
  final _idTypes = ['Aadhaar Card', 'PAN Card', 'Passport', "Voter's ID"];
  final _branches = [
    'MG Road, Bangalore',
    'Koramangala, Bangalore',
    'Indiranagar, Bangalore',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Loan')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Step Indicator
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: List.generate(3, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.divider,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: i < _step
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : AppColors.textGrey,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i < _step
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: _buildStep(),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _onNext,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(_step == 2 ? 'Submit Application' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loan Details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Select your preferred loan type and amount',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _label('Loan Type'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _loanType,
          decoration: const InputDecoration(),
          items: _loanTypes
              .map((t) =>
                  DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _loanType = v),
        ),
        const SizedBox(height: 20),
        _label('Loan Amount (₹)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(prefixText: '₹ '),
          validator: (v) {
            final amt = int.tryParse(v ?? '') ?? 0;
            if (amt < 10000) return 'Minimum loan amount is ₹10,000';
            return null;
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.goldLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.gold, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Gold weight required will be calculated based on today\'s gold rate.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('We need some personal information for KYC',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _label('Full Name'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration:
              const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
          validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        _label('Date of Birth'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dobController,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today_outlined),
              hintText: 'DD/MM/YYYY'),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 20),
        _label('ID Proof Type'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _idType,
          decoration:
              const InputDecoration(prefixIcon: Icon(Icons.badge_outlined)),
          items: _idTypes
              .map((t) =>
                  DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _idType = v),
        ),
        const SizedBox(height: 20),
        _label('ID Number'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _panController,
          decoration: const InputDecoration(
              hintText: 'Enter ID number',
              prefixIcon: Icon(Icons.numbers_outlined)),
          textCapitalization: TextCapitalization.characters,
          validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Branch & Address',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Select branch and enter your address',
            style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _label('Nearest Branch'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _branch,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined)),
          items: _branches
              .map((b) =>
                  DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => setState(() => _branch = v),
        ),
        const SizedBox(height: 20),
        _label('Current Address'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Enter your complete address'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 20),
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Application Summary',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark)),
              const Divider(height: 20),
              _summaryRow('Loan Type', _loanType ?? '-'),
              _summaryRow('Loan Amount', '₹${_amountController.text}'),
              _summaryRow('Applicant', _nameController.text),
              _summaryRow('ID Type', _idType ?? '-'),
              _summaryRow('Branch', _branch ?? '-'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark),
      );

  void _onNext() async {
    if (_step < 2) {
      if (_formKey.currentState?.validate() == true) {
        setState(() => _step++);
      }
    } else {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _loading = false);
        _showSuccess();
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your loan application has been received. Our executive will contact you within 24 hours.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text('Reference: GL-2024-003',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popUntil(
                      context, ModalRoute.withName('/home'));
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';
import '../../widgets/glass_card.dart';

class PanVerifyScreen extends StatefulWidget {
  const PanVerifyScreen({super.key});

  @override
  State<PanVerifyScreen> createState() => _PanVerifyScreenState();
}

class _PanVerifyScreenState extends State<PanVerifyScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _panCtrl   = TextEditingController();
  bool  _loading   = false;
  String? _error;
  Map<String, dynamic>? _result;

  static final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  @override
  void dispose() {
    _panCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiClient.instance.post(
        '/member/kyc/verify-pan',
        data: {'pan': _panCtrl.text.trim().toUpperCase()},
      );
      if (mounted) setState(() { _result = res.data['data'] as Map<String, dynamic>?; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().contains('422')
              ? 'PAN verification failed. Check the number and try again.'
              : 'Network error. Please try again.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('PAN Verification',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _result != null ? _SuccessView(result: _result!, onDone: () => context.pop()) : Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.credit_card_rounded, color: AppTheme.primary, size: 48),
            const SizedBox(height: 20),
            const Text('Enter PAN Details',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Your Permanent Account Number (PAN) is required for KYC compliance.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),

            GlassCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PAN Number', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _panCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    _UpperCaseFormatter(),
                  ],
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, letterSpacing: 3,
                      fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'ABCDE1234F',
                    hintStyle: TextStyle(color: AppTheme.textMuted, letterSpacing: 2),
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  validator: (v) {
                    final val = v?.trim().toUpperCase() ?? '';
                    if (val.isEmpty) return 'PAN is required';
                    if (!_panRegex.hasMatch(val)) return 'Enter a valid 10-character PAN';
                    return null;
                  },
                ),
              ]),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                ]),
              ),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Verify PAN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Your PAN details are secured and used only for KYC verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onDone;
  const _SuccessView({required this.result, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success.withOpacity(0.15),
          ),
          child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 44),
        ),
        const SizedBox(height: 24),
        const Text('PAN Verified!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Your PAN has been successfully verified.',
            style: TextStyle(color: AppTheme.textMuted)),
        const SizedBox(height: 32),

        if (result['name'] != null)
          GlassCard(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Name on PAN', style: TextStyle(color: AppTheme.textMuted)),
              Text(result['name'].toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

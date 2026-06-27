import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) _focusNodes[index + 1].requestFocus();
      _checkAutoSubmit();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _checkAutoSubmit() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) _verify(otp);
  }

  Future<void> _verify(String otp) async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(widget.phone, otp);

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid OTP'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
    // On success GoRouter redirect handles navigation automatically
  }

  Future<void> _resendOtp() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendOtp(widget.phone);
    if (ok) {
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
          ),
        ),
        onChanged: (val) => _onDigitChanged(val, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = widget.phone.replaceRange(3, widget.phone.length - 2, '****');

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(backgroundColor: AppTheme.bgMain, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verify OTP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to $maskedPhone',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 40),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        // OTP boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, _buildDigitBox),
                        ),
                        const SizedBox(height: 32),

                        // Verify button
                        ElevatedButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  final otp = _controllers.map((c) => c.text).join();
                                  if (otp.length == 6) _verify(otp);
                                },
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Verify OTP'),
                        ),
                        const SizedBox(height: 20),

                        // Resend
                        if (_resendSeconds > 0)
                          Text(
                            'Resend OTP in ${_resendSeconds}s',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          )
                        else
                          TextButton(
                            onPressed: _resendOtp,
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(color: AppTheme.primary, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_theme.dart';
import '../../core/api_client.dart';

/// Opens Digio's Aadhaar OTP flow in a WebView.
/// After completion, Digio redirects to /api/member/kyc/callback which closes the window.
class AadhaarVerifyScreen extends StatefulWidget {
  const AadhaarVerifyScreen({super.key});

  @override
  State<AadhaarVerifyScreen> createState() => _AadhaarVerifyScreenState();
}

class _AadhaarVerifyScreenState extends State<AadhaarVerifyScreen> {
  WebViewController? _controller;
  bool _initiating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startKyc();
  }

  Future<void> _startKyc() async {
    try {
      final res = await ApiClient.instance.post('/member/kyc/start-aadhaar');
      final kycUrl = res.data['kyc_url'] as String?;

      if (kycUrl == null) throw Exception('No KYC URL returned');

      final ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) {
            // Detect when Digio redirects to our callback URL
            if (request.url.contains('/kyc/callback') ||
                request.url.contains('kyc_complete')) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aadhaar verification submitted!'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ))
        ..loadRequest(Uri.parse(kycUrl));

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _initiating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not start KYC: ${e.toString()}';
          _initiating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('Aadhaar Verification',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _initiating
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text('Preparing verification…',
                    style: TextStyle(color: AppTheme.textMuted)),
              ],
            ))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppTheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() { _initiating = true; _error = null; });
                          _startKyc();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ]),
                  ),
                )
              : WebViewWidget(controller: _controller!),
    );
  }
}

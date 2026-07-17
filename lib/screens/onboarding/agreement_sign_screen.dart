import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_theme.dart';

/// WebView for Digio e-Sign agreement flow.
/// The esignUrl is passed as a route extra from the group detail screen.
class AgreementSignScreen extends StatefulWidget {
  final String esignUrl;
  final String? groupName;

  const AgreementSignScreen({
    super.key,
    required this.esignUrl,
    this.groupName,
  });

  @override
  State<AgreementSignScreen> createState() => _AgreementSignScreenState();
}

class _AgreementSignScreenState extends State<AgreementSignScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _signed  = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
        onNavigationRequest: (request) {
          // Detect successful e-sign completion
          if (request.url.contains('digio_esign_complete') ||
              request.url.contains('/kyc/callback') ||
              request.url.contains('sign_complete')) {
            if (mounted && !_signed) {
              setState(() => _signed = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agreement signed successfully!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) context.pop(true);
              });
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.esignUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('e-Sign Agreement',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          if (widget.groupName != null)
            Text(widget.groupName!,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(false),
        ),
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ]),
    );
  }
}

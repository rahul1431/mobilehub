import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_theme.dart';
import '../../../core/api_client.dart';
import '../../../widgets/glass_card.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _loading = true;
  String _kycStatus = 'pending';
  List<dynamic> _docs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.instance.get('/member/kyc/status');
      if (mounted) {
        setState(() {
          _kycStatus = res.data['kyc_status'] as String? ?? 'pending';
          _docs      = res.data['documents'] as List? ?? [];
          _loading   = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load documents.';
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
        title: const Text('My Documents',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // KYC Status card
                      _KycStatusCard(status: _kycStatus),
                      const SizedBox(height: 20),

                      if (_kycStatus != 'verified') ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/kyc'),
                            icon: const Icon(Icons.verified_user_outlined),
                            label: const Text('Complete KYC'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (_docs.isEmpty) ...[
                        const Center(
                          child: Column(children: [
                            SizedBox(height: 40),
                            Icon(Icons.folder_open_rounded,
                                color: AppTheme.textMuted, size: 56),
                            SizedBox(height: 12),
                            Text('No documents yet',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                            SizedBox(height: 6),
                            Text('Complete your KYC to see documents here.',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          ]),
                        ),
                      ] else ...[
                        const Text('Documents',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...(_docs.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DocCard(doc: doc as Map<String, dynamic>),
                        ))),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _KycStatusCard extends StatelessWidget {
  final String status;
  const _KycStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label, desc) = switch (status) {
      'verified' => (
          AppTheme.success,
          Icons.verified_rounded,
          'KYC Verified',
          'Your identity has been verified. You can participate in all chit groups.'
        ),
      'rejected' => (
          AppTheme.error,
          Icons.cancel_rounded,
          'KYC Rejected',
          'Your KYC was rejected. Please re-submit your documents.'
        ),
      _ => (
          AppTheme.warning,
          Icons.pending_actions_rounded,
          'KYC Pending',
          'Complete your KYC to unlock full access.'
        ),
    };

    return GlassCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4)),
        ])),
      ]),
    );
  }
}

class _DocCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DocCard({required this.doc});

  IconData get _icon => switch (doc['doc_type'] as String?) {
    'aadhaar'   => Icons.fingerprint_rounded,
    'pan'       => Icons.credit_card_rounded,
    'photo'     => Icons.person_rounded,
    'agreement' => Icons.description_rounded,
    _           => Icons.insert_drive_file_rounded,
  };

  String get _label => switch (doc['doc_type'] as String?) {
    'aadhaar'   => 'Aadhaar Card',
    'pan'       => 'PAN Card',
    'photo'     => 'Photograph',
    'agreement' => 'Signed Agreement',
    _           => 'Document',
  };

  @override
  Widget build(BuildContext context) {
    final verified = doc['verified'] == true || doc['verified'] == 1;
    final path     = doc['storage_path'] as String?;

    return GlassCard(
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withOpacity(0.12),
          ),
          child: Icon(_icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (verified ? AppTheme.success : AppTheme.warning).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                verified ? 'Verified' : 'Pending',
                style: TextStyle(
                  color: verified ? AppTheme.success : AppTheme.warning,
                  fontSize: 11, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ])),
        if (path != null && doc['doc_type'] == 'agreement')
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppTheme.primary),
            onPressed: () async {
              final uri = Uri.tryParse(path);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            tooltip: 'Download',
          ),
      ]),
    );
  }
}

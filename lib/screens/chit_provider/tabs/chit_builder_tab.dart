import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/provider_state.dart';
import 'package:provider/provider.dart';

class ChitBuilderTab extends StatefulWidget {
  const ChitBuilderTab({super.key});

  @override
  State<ChitBuilderTab> createState() => _ChitBuilderTabState();
}

class _ChitBuilderTabState extends State<ChitBuilderTab> {
  final GlobalKey _previewKey = GlobalKey();
  final _nameCtrl    = TextEditingController(text: 'My Chit Group');
  final _amountCtrl  = TextEditingController(text: '5000');
  final _membersCtrl = TextEditingController(text: '20');
  final _contactCtrl = TextEditingController(text: '+91 98765 43210');

  int _templateIndex = 0;
  bool _sharing = false;

  static const _templates = [
    _Template(primaryColor: Color(0xFF00C896), label: 'Emerald'),
    _Template(primaryColor: Color(0xFF6C63FF), label: 'Violet'),
    _Template(primaryColor: Color(0xFFFFD700), label: 'Gold'),
    _Template(primaryColor: Color(0xFFFF4B5C), label: 'Ruby'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _membersCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _sharePreview() async {
    setState(() => _sharing = true);
    try {
      final boundary = _previewKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file    = File('${tempDir.path}/chit_builder_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${_nameCtrl.text.trim()} — Join our chit fund!\n'
            '₹${_amountCtrl.text.trim()}/month · ${_membersCtrl.text.trim()} members\n'
            'Contact: ${_contactCtrl.text.trim()}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e'),
              backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = _templates[_templateIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Chit Builder',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Create a branded marketing card for your chit group',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        const SizedBox(height: 20),

        // Live preview
        RepaintBoundary(
          key: _previewKey,
          child: _ChitCard(
            template:   template,
            name:       _nameCtrl.text,
            amount:     _amountCtrl.text,
            members:    _membersCtrl.text,
            contact:    _contactCtrl.text,
          ),
        ),

        const SizedBox(height: 20),

        // Template picker
        Row(children: [
          const Text('Template: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(width: 10),
          ..._templates.asMap().entries.map((e) => GestureDetector(
            onTap: () => setState(() => _templateIndex = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: e.value.primaryColor,
                border: Border.all(
                  color: _templateIndex == e.key ? Colors.white : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
          )),
        ]),

        const SizedBox(height: 20),

        // Input fields
        _field(_nameCtrl,   'Group Name', Icons.group_work_rounded),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _field(_amountCtrl, 'Monthly (₹)', Icons.currency_rupee_rounded,
              type: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _field(_membersCtrl, 'Members', Icons.people_rounded,
              type: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        _field(_contactCtrl, 'Contact Info', Icons.phone_rounded,
            type: TextInputType.phone),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sharing ? null : _sharePreview,
            icon: _sharing
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.share_rounded),
            label: Text(_sharing ? 'Preparing…' : 'Share Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 18),
      ),
    );
  }
}

class _Template {
  final Color primaryColor;
  final String label;
  const _Template({required this.primaryColor, required this.label});
}

class _ChitCard extends StatelessWidget {
  final _Template template;
  final String name, amount, members, contact;

  const _ChitCard({
    required this.template,
    required this.name,
    required this.amount,
    required this.members,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            template.primaryColor.withOpacity(0.3),
            const Color(0xFF060B14),
            template.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: template.primaryColor.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: template.primaryColor.withOpacity(0.2),
              border: Border.all(color: template.primaryColor, width: 1.5),
            ),
            child: Icon(Icons.savings_rounded, color: template.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('APNA SAVING',
                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
            Text('Chit Fund', style: TextStyle(color: template.primaryColor,
                fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ]),

        const SizedBox(height: 24),

        Text(
          name.isEmpty ? 'My Chit Group' : name,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Row(children: [
          _stat('₹${amount.isEmpty ? '0' : amount}', 'Per Month',
              template.primaryColor),
          const SizedBox(width: 24),
          _stat('${members.isEmpty ? '0' : members}', 'Members',
              Colors.white),
          const SizedBox(width: 24),
          _stat('${members.isEmpty ? '0' : members} Months', 'Duration',
              AppTheme.gold),
        ]),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(children: [
            Icon(Icons.phone_rounded, color: template.primaryColor, size: 16),
            const SizedBox(width: 8),
            Text(contact.isEmpty ? '+91 9999999999' : contact,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '🔒 ROSCA Certified  ·  Transparent Bidding',
            style: TextStyle(color: template.primaryColor.withOpacity(0.7), fontSize: 10),
          ),
        ),
      ]),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(
          color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }
}

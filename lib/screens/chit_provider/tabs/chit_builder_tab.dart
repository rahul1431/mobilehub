import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class ChitBuilderTab extends StatelessWidget {
  const ChitBuilderTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.construction_rounded, color: AppTheme.textMuted, size: 56),
        SizedBox(height: 16),
        Text('Coming Soon', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('This feature will be available\nin an upcoming phase', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
      ]),
    );
  }
}

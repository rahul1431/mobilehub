import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bar_chart_rounded, color: AppTheme.textMuted, size: 56),
        SizedBox(height: 16),
        Text('Reports', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Platform analytics & compliance reports\n(Coming in Phase 8)', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
      ]),
    );
  }
}

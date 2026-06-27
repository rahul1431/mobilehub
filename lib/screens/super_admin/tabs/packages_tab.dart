import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class PackagesTab extends StatelessWidget {
  const PackagesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_rounded, color: AppTheme.textMuted, size: 56),
        SizedBox(height: 16),
        Text('Chit Packages', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Create and manage chit templates\n(Coming in Phase 2)', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
      ]),
    );
  }
}

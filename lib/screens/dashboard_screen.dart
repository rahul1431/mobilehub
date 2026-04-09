import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../core/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.0,
            colors: [Color(0xFF10192B), AppTheme.bgMain],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildMetricsGrid(),
              const SizedBox(height: 32),
              _buildPerformanceReport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Alpha Hub Mobile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.black, color: Colors.white)),
            Text("Probing Market Pulse...", style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const CircleAvatar(
          backgroundColor: AppTheme.bgGlass,
          child: Icon(Icons.person_outline, color: AppTheme.primary),
        )
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: const [
        _MetricItem(label: "AI ACCURACY", value: "84.2%", color: AppTheme.success),
        _MetricItem(label: "ACTIVE PROBES", value: "12", color: AppTheme.primary),
      ],
    );
  }

  Widget _buildPerformanceReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Performance Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text("DAILY", style: TextStyle(color: AppTheme.success, fontSize: 10, fontWeight: FontWeight.black)),
            )
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              _buildReportRow("Best 24h Yield", "+12.4%", AppTheme.success),
              const Divider(color: Colors.white10),
              _buildReportRow("Exp. Value (EV)", "\$4,250", AppTheme.accent),
              const Divider(color: Colors.white10),
              _buildReportRow("Win Streak", "8", AppTheme.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

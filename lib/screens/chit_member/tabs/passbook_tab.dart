import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/glass_card.dart';

class PassbookTab extends StatefulWidget {
  const PassbookTab({super.key});

  @override
  State<PassbookTab> createState() => _PassbookTabState();
}

class _PassbookTabState extends State<PassbookTab> {
  bool _requestingPdf = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadPassbook();
    });
  }

  Future<void> _exportPdf() async {
    setState(() => _requestingPdf = true);
    final msg = await context.read<MemberProvider>().requestPassbookPdf();
    setState(() => _requestingPdf = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Your passbook PDF is being generated.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MemberProvider>();

    return RefreshIndicator(
      onRefresh: () => state.loadPassbook(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: CustomScrollView(
        slivers: [
          // ── Summary header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SummaryCard(
                summary: state.passbookSummary,
                onExport: _exportPdf,
                exporting: _requestingPdf,
              ),
            ),
          ),

          // ── Loading / empty / list ──────────────────────────────────────
          if (state.passbookLoading && state.ledger.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            )
          else if (state.ledger.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.menu_book_rounded, color: AppTheme.textMuted, size: 56),
                  const SizedBox(height: 16),
                  const Text('No transactions yet',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Your chit payments and dividends will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted)),
                ]),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LedgerRow(entry: state.ledger[i] as Map<String, dynamic>),
                  ),
                  childCount: state.ledger.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.onExport,
    required this.exporting,
  });

  final Map<String, dynamic>? summary;
  final VoidCallback onExport;
  final bool exporting;

  @override
  Widget build(BuildContext context) {
    final totalPaid     = (summary?['total_paid']     as num? ?? 0).toDouble();
    final totalReceived = (summary?['total_received'] as num? ?? 0).toDouble();
    final netSavings    = totalReceived - totalPaid;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Passbook Summary',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton.icon(
                onPressed: exporting ? null : onExport,
                icon: exporting
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppTheme.primary),
                label: Text(exporting ? 'Generating…' : 'Export PDF',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _stat('Total Paid', '₹${totalPaid.toStringAsFixed(0)}', AppTheme.error)),
            Expanded(child: _stat('Dividends', '₹${totalReceived.toStringAsFixed(0)}', AppTheme.success)),
            Expanded(child: _stat(
              'Net',
              '${netSavings >= 0 ? "+" : ""}₹${netSavings.toStringAsFixed(0)}',
              netSavings >= 0 ? AppTheme.success : AppTheme.error,
            )),
          ]),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ],
  );
}

// ── Ledger Row ────────────────────────────────────────────────────────────────

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});
  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final type   = entry['type'] as String? ?? 'payment';
    final label  = entry['label'] as String? ?? '';
    final amount = (entry['amount'] as num? ?? 0).toDouble();
    final status = entry['status'] as String? ?? '';
    final rawDate = entry['date'];

    DateTime? date;
    if (rawDate is String) date = DateTime.tryParse(rawDate);

    final isCredit = amount > 0;
    final amtColor = isCredit ? AppTheme.success : AppTheme.error;
    final icon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Icon dot
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: amtColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: amtColor, size: 18),
          ),
          const SizedBox(width: 12),

          // Label + date
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              if (date != null) ...[
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ]),
          ),

          // Amount + status
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${isCredit ? "+" : ""}₹${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(color: amtColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (status.isNotEmpty)
              Text(status,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ],
      ),
    );
  }
}

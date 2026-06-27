import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../models/payment_model.dart';
import '../../../providers/provider_state.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderState>().loadCollections();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Collected')],
        ),
      ),
      body: Consumer<ProviderState>(builder: (_, state, __) {
        if (state.collectionsLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        return TabBarView(
          controller: _tabs,
          children: [
            _PaymentList(
              payments: state.pendingPayments,
              emptyMsg: 'No pending payments',
              emptyIcon: Icons.check_circle_outline,
              onRefresh: () => state.loadCollections(),
              onRecord: (p) => _showRecordSheet(context, state, p),
            ),
            _PaymentList(
              payments: state.recentPayments,
              emptyMsg: 'No collected payments yet',
              emptyIcon: Icons.payments_outlined,
              onRefresh: () => state.loadCollections(),
            ),
          ],
        );
      }),
    );
  }

  void _showRecordSheet(BuildContext context, ProviderState state, PaymentModel payment) {
    String method = 'cash';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Text('Record Payment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${payment.memberDisplayName} · ₹${payment.totalDue.toStringAsFixed(0)}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            if (payment.penaltyAmount > 0) ...[
              const SizedBox(height: 4),
              Text('Includes ₹${payment.penaltyAmount.toStringAsFixed(0)} penalty',
                  style: const TextStyle(color: AppTheme.warning, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft,
                child: Text('Payment Method', style: TextStyle(color: Colors.white70, fontSize: 13))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _MethodBtn(label: 'Cash', icon: Icons.money,
                  selected: method == 'cash', onTap: () => setSt(() => method = 'cash'))),
              const SizedBox(width: 10),
              Expanded(child: _MethodBtn(label: 'Bank Transfer', icon: Icons.account_balance_outlined,
                  selected: method == 'bank_transfer', onTap: () => setSt(() => method = 'bank_transfer'))),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await state.recordPayment(payment.id, method);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.collectionsError ?? 'Failed to record payment'),
                    backgroundColor: AppTheme.error,
                  ));
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Payment'),
            )),
            const SizedBox(height: 8),
          ]),
        );
      }),
    );
  }
}

class _PaymentList extends StatelessWidget {
  final List<PaymentModel> payments;
  final String emptyMsg;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final void Function(PaymentModel)? onRecord;

  const _PaymentList({
    required this.payments,
    required this.emptyMsg,
    required this.emptyIcon,
    required this.onRefresh,
    this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(emptyIcon, color: AppTheme.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(emptyMsg, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _PaymentTile(payment: payments[i], onRecord: onRecord),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentModel payment;
  final void Function(PaymentModel)? onRecord;
  const _PaymentTile({required this.payment, this.onRecord});

  @override
  Widget build(BuildContext context) {
    final isPending = payment.isPending;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? AppTheme.warning.withOpacity(0.3) : Colors.white12,
        ),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: (isPending ? AppTheme.warning : AppTheme.success).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(isPending ? Icons.pending_outlined : Icons.check_circle_outline,
              color: isPending ? AppTheme.warning : AppTheme.success, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(payment.memberDisplayName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            '${payment.groupName ?? 'Group'} · Cycle #${payment.cycleNumber ?? '?'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (payment.penaltyAmount > 0)
            Text('+₹${payment.penaltyAmount.toStringAsFixed(0)} penalty',
                style: const TextStyle(color: AppTheme.warning, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${payment.totalDue.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          if (isPending && onRecord != null)
            TextButton(
              onPressed: () => onRecord!(payment),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Record', style: TextStyle(fontSize: 12)),
            )
          else if (!isPending)
            Text(
              _fmtDate(payment.paidAt),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
        ]),
      ]),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _MethodBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodBtn({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppTheme.primary : Colors.white12),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? AppTheme.primary : AppTheme.textMuted, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? AppTheme.primary : Colors.white60, fontSize: 12)),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/app_theme.dart';
import '../../../models/payment_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/glass_card.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  late final Razorpay _razorpay;
  int? _pendingPaymentId;
  bool _checkoutOpen = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().loadPayments();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ── Razorpay Checkout ──────────────────────────────────────────────────────

  Future<void> _initiatePayment(PaymentModel payment) async {
    if (_checkoutOpen) return;
    setState(() {
      _pendingPaymentId = payment.id;
      _checkoutOpen = true;
    });

    final order = await context.read<MemberProvider>().createOrder(payment.id);
    if (!mounted) return;

    if (order == null) {
      setState(() { _checkoutOpen = false; _pendingPaymentId = null; });
      _snack('Could not create order. Please try again.', AppTheme.error);
      return;
    }

    final profile = context.read<AuthProvider>().profile;
    _razorpay.open({
      'key': order['key_id'],
      'amount': order['amount'],
      'order_id': order['order_id'],
      'currency': order['currency'] ?? 'INR',
      'name': 'Apna Saving',
      'description': '${payment.groupName ?? "Chit"}'
          '${payment.cycleNumber != null ? " – Cycle #${payment.cycleNumber}" : ""}',
      'prefill': {
        'contact': profile?.phone ?? '',
        'name': profile?.displayName ?? '',
      },
      'theme': {'color': '#6C63FF'},
    });
  }

  void _onSuccess(PaymentSuccessResponse resp) async {
    setState(() { _checkoutOpen = false; });
    final ok = await context.read<MemberProvider>().confirmPayment(
      orderId: resp.orderId ?? '',
      paymentId: resp.paymentId ?? '',
      signature: resp.signature ?? '',
    );
    setState(() { _pendingPaymentId = null; });
    _snack(
      ok ? 'Payment successful!' : 'Payment received, pending confirmation.',
      ok ? AppTheme.success : AppTheme.warning,
    );
  }

  void _onError(PaymentFailureResponse resp) {
    setState(() { _checkoutOpen = false; _pendingPaymentId = null; });
    _snack('Payment failed: ${resp.message ?? "Unknown error"}', AppTheme.error);
  }

  void _onWallet(ExternalWalletResponse _) {
    setState(() { _checkoutOpen = false; _pendingPaymentId = null; });
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MemberProvider>();

    return RefreshIndicator(
      onRefresh: () => state.loadPayments(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SummaryCard(payments: state.payments),
            ),
          ),

          if (state.paymentsLoading && state.payments.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            )
          else if (state.payments.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.receipt_long_rounded, color: AppTheme.textMuted, size: 56),
                  const SizedBox(height: 16),
                  const Text('No payments yet',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Your payment history will appear here',
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
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PaymentCard(
                      payment: state.payments[i],
                      isPaying: _pendingPaymentId == state.payments[i].id,
                      onPay: () => _initiatePayment(state.payments[i]),
                    ),
                  ),
                  childCount: state.payments.length,
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
  const _SummaryCard({required this.payments});
  final List<PaymentModel> payments;

  @override
  Widget build(BuildContext context) {
    final pending = payments.where((p) => p.isPending).length;
    final paid    = payments.where((p) => p.isPaid).length;
    final due     = payments.where((p) => p.isPending).fold(0.0, (s, p) => s + p.totalDue);

    return GlassCard(
      child: Row(children: [
        Expanded(child: _item('Pending', '$pending', AppTheme.warning)),
        Container(width: 1, height: 40, color: Colors.white12),
        Expanded(child: _item('Paid', '$paid', AppTheme.success)),
        Container(width: 1, height: 40, color: Colors.white12),
        Expanded(child: _item('Total Due', '₹${due.toStringAsFixed(0)}', AppTheme.error)),
      ]),
    );
  }

  Widget _item(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
  ]);
}

// ── Payment Card ─────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.isPaying,
    required this.onPay,
  });

  final PaymentModel payment;
  final bool isPaying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final borderColor = payment.isPaid
        ? AppTheme.success.withOpacity(0.3)
        : AppTheme.warning.withOpacity(0.35);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(payment.groupName ?? 'Chit Group',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                if (payment.cycleNumber != null)
                  Text('Cycle #${payment.cycleNumber}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ]),
            ),
            _StatusBadge(status: payment.status),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '₹${payment.totalDue.toStringAsFixed(2)}',
                style: TextStyle(
                  color: payment.isPaid ? AppTheme.success : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (payment.penaltyAmount > 0)
                Text('Includes ₹${payment.penaltyAmount.toStringAsFixed(0)} penalty',
                    style: const TextStyle(color: AppTheme.error, fontSize: 11)),
              if (payment.paidAt != null)
                Text('Paid on ${fmt.format(payment.paidAt!)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),

            if (payment.isPending)
              ElevatedButton(
                onPressed: isPaying ? null : onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isPaying
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case 'paid':     color = AppTheme.success; break;
      case 'failed':   color = AppTheme.error;   break;
      case 'refunded': color = AppTheme.primary;  break;
      default:         color = AppTheme.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

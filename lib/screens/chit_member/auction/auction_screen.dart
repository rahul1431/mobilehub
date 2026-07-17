import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../core/app_theme.dart';
import '../../../core/api_client.dart';
import '../../../core/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_card.dart';

/// Live auction screen for a cycle in 'auction' status.
/// Subscribes to Pusher channel `cycle.{cycleId}` and listens for `bid.placed`.
class AuctionScreen extends StatefulWidget {
  final int cycleId;
  final double totalPot;
  final String groupName;
  final int cycleNumber;

  const AuctionScreen({
    super.key,
    required this.cycleId,
    required this.totalPot,
    required this.groupName,
    required this.cycleNumber,
  });

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  final _pusher = PusherChannelsFlutter.getInstance();
  final _bidCtrl = TextEditingController();
  final _bids = <Map<String, dynamic>>[];

  bool _connected = false;
  bool _submitting = false;
  String? _error;
  String? _bidError;

  double get _minBid => widget.totalPot * 0.70;

  @override
  void initState() {
    super.initState();
    _loadBids();
    _connectPusher();
  }

  @override
  void dispose() {
    _pusher.unsubscribe(channelName: 'cycle.${widget.cycleId}');
    _pusher.disconnect();
    _bidCtrl.dispose();
    super.dispose();
  }

  // ── Pusher ─────────────────────────────────────────────────────────────────

  Future<void> _connectPusher() async {
    try {
      await _pusher.init(
        apiKey: AppConstants.pusherKey,
        cluster: AppConstants.pusherCluster,
        onError: (msg, code, _) {
          if (mounted) setState(() => _error = 'Pusher error: $msg');
        },
        onConnectionStateChange: (prev, curr) {
          if (mounted) setState(() => _connected = curr == 'CONNECTED');
        },
      );

      await _pusher.subscribe(
        channelName: 'cycle.${widget.cycleId}',
        onEvent: (event) {
          if (event.eventName == 'bid.placed') {
            try {
              final data = jsonDecode(event.data as String) as Map<String, dynamic>;
              if (mounted) {
                setState(() {
                  // Replace existing bid from same member
                  _bids.removeWhere((b) => b['member_id'] == data['member_id']);
                  _bids.add(data);
                  _bids.sort((a, b) =>
                      (a['bid_amount'] as num).compareTo(b['bid_amount'] as num));
                });
              }
            } catch (_) {}
          }
        },
      );

      await _pusher.connect();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not connect to live auction: $e');
    }
  }

  // ── Load existing bids ────────────────────────────────────────────────────

  Future<void> _loadBids() async {
    try {
      final res = await ApiClient.instance.get('/member/cycles/${widget.cycleId}/bids');
      final List list = res.data['data'] ?? [];
      if (mounted) {
        setState(() {
          _bids.clear();
          for (final b in list) {
            _bids.add(b as Map<String, dynamic>);
          }
          _bids.sort((a, b) =>
              (a['bid_amount'] as num).compareTo(b['bid_amount'] as num));
        });
      }
    } catch (_) {}
  }

  // ── Place bid ─────────────────────────────────────────────────────────────

  Future<void> _placeBid() async {
    final val = double.tryParse(_bidCtrl.text.trim());
    if (val == null) {
      setState(() => _bidError = 'Enter a valid amount.');
      return;
    }
    if (val < _minBid) {
      setState(() => _bidError =
          'Minimum bid is ₹${_minBid.toStringAsFixed(0)} (70% of pot).');
      return;
    }
    setState(() { _submitting = true; _bidError = null; });
    try {
      await ApiClient.instance.post('/member/bids', data: {
        'cycle_id': widget.cycleId,
        'bid_amount': val,
      });
      _bidCtrl.clear();
      // Own bid comes back via Pusher for other devices; manually add here
      final profile = context.read<AuthProvider>().profile;
      final myBid = {
        'cycle_id': widget.cycleId,
        'member_id': profile?.id,
        'bid_amount': val,
        'placed_at': DateTime.now().toIso8601String(),
        'member': {'full_name': profile?.displayName, 'phone': profile?.phone},
      };
      setState(() {
        _bids.removeWhere((b) => b['member_id'] == profile?.id);
        _bids.add(myBid);
        _bids.sort((a, b) =>
            (a['bid_amount'] as num).compareTo(b['bid_amount'] as num));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid placed successfully!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _bidError = e.toString().contains('422')
          ? 'Bid rejected by server. Check amount.'
          : 'Failed to place bid. Try again.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.groupName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Cycle #${widget.cycleNumber} — Live Auction',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _connected ? AppTheme.success : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Text(_connected ? 'Live' : 'Connecting…',
                  style: TextStyle(
                      color: _connected ? AppTheme.success : AppTheme.textMuted,
                      fontSize: 12)),
            ]),
          ),
        ],
      ),
      body: Column(children: [
        // ── Pot info card ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _potStat('Total Pot', '₹${widget.totalPot.toStringAsFixed(0)}',
                    AppTheme.gold),
                Container(width: 1, height: 40, color: Colors.white12),
                _potStat('Min Bid', '₹${_minBid.toStringAsFixed(0)}', AppTheme.warning),
                Container(width: 1, height: 40, color: Colors.white12),
                _potStat('Bids Placed', '${_bids.length}', AppTheme.primary),
              ],
            ),
          ),
        ),

        // ── Bids list ─────────────────────────────────────────────────────
        Expanded(
          child: _bids.isEmpty
              ? const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.gavel_rounded, color: AppTheme.textMuted, size: 48),
                    SizedBox(height: 12),
                    Text('No bids yet. Be the first!',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _bids.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _BidRow(
                    bid: _bids[i],
                    rank: i + 1,
                    isWinning: i == 0,
                    myId: context.read<AuthProvider>().profile?.id,
                  ),
                ),
        ),

        // ── Bid form ──────────────────────────────────────────────────────
        _BidForm(
          controller: _bidCtrl,
          submitting: _submitting,
          error: _bidError,
          minBid: _minBid,
          onSubmit: _placeBid,
        ),
      ]),
    );
  }

  Widget _potStat(String label, String value, Color color) =>
      Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ]);
}

// ── Bid Row ───────────────────────────────────────────────────────────────────

class _BidRow extends StatelessWidget {
  const _BidRow({
    required this.bid,
    required this.rank,
    required this.isWinning,
    required this.myId,
  });

  final Map<String, dynamic> bid;
  final int rank;
  final bool isWinning;
  final int? myId;

  @override
  Widget build(BuildContext context) {
    final amount   = (bid['bid_amount'] as num).toDouble();
    final member   = bid['member'] as Map<String, dynamic>?;
    final name     = member?['full_name'] as String? ?? member?['phone'] as String? ?? 'Member';
    final isMe     = bid['member_id'] == myId;
    final color    = isWinning ? AppTheme.gold : isMe ? AppTheme.primary : AppTheme.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isWinning
            ? AppTheme.gold.withOpacity(0.08)
            : isMe
                ? AppTheme.primary.withOpacity(0.06)
                : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(isWinning || isMe ? 0.3 : 0.07)),
      ),
      child: Row(children: [
        // Rank badge
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Center(
            child: isWinning
                ? Icon(Icons.emoji_events_rounded, color: AppTheme.gold, size: 16)
                : Text('#$rank', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(isMe ? 'You' : name,
                style: TextStyle(color: isMe ? AppTheme.primary : Colors.white,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
            if (isWinning) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('WINNING',
                    style: TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ]),
        ])),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}

// ── Bid Form ──────────────────────────────────────────────────────────────────

class _BidForm extends StatelessWidget {
  const _BidForm({
    required this.controller,
    required this.submitting,
    required this.error,
    required this.minBid,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool submitting;
  final String? error;
  final double minBid;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Place Your Bid',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text('Lowest bid wins. Minimum: ₹${minBid.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter bid amount (₹)',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppTheme.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: submitting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Bid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      ]),
    );
  }
}

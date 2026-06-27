class CycleModel {
  final int id;
  final int groupId;
  final int cycleNumber;
  final DateTime dueDate;
  final double totalPot;
  final double? winningBid;
  final int? winnerId;
  final String? winnerName;
  final double? dividendPerMember;
  final String cycleMethod; // auction, lottery, manual
  final String status; // open, closed
  final DateTime? closedAt;

  const CycleModel({
    required this.id,
    required this.groupId,
    required this.cycleNumber,
    required this.dueDate,
    required this.totalPot,
    this.winningBid,
    this.winnerId,
    this.winnerName,
    this.dividendPerMember,
    required this.cycleMethod,
    required this.status,
    this.closedAt,
  });

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    final winner = json['winner'] as Map<String, dynamic>?;
    return CycleModel(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      cycleNumber: json['cycle_number'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      totalPot: (json['total_pot'] as num).toDouble(),
      winningBid: json['winning_bid'] != null ? (json['winning_bid'] as num).toDouble() : null,
      winnerId: json['winner_id'] as int?,
      winnerName: winner?['full_name'] as String? ?? winner?['phone'] as String?,
      dividendPerMember: json['dividend_per_member'] != null
          ? (json['dividend_per_member'] as num).toDouble()
          : null,
      cycleMethod: json['cycle_method'] as String? ?? 'manual',
      status: json['status'] as String? ?? 'open',
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at']) : null,
    );
  }

  bool get isOpen   => status == 'open';
  bool get isClosed => status == 'closed';

  String get methodLabel {
    switch (cycleMethod) {
      case 'auction': return 'Online Auction';
      case 'lottery': return 'Lottery';
      case 'manual':  return 'Manual Pick';
      default:        return cycleMethod;
    }
  }
}

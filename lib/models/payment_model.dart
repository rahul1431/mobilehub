class PaymentModel {
  final int id;
  final int cycleId;
  final int memberId;
  final int groupId;
  final double amount;
  final String paymentMethod; // cash, bank_transfer, razorpay, enach
  final String status; // pending, paid, failed
  final double penaltyAmount;
  final String? memberName;
  final String? memberPhone;
  final String? groupName;
  final int? cycleNumber;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.cycleId,
    required this.memberId,
    required this.groupId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.penaltyAmount = 0,
    this.memberName,
    this.memberPhone,
    this.groupName,
    this.cycleNumber,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    final group  = json['group']  as Map<String, dynamic>?;
    final cycle  = json['cycle']  as Map<String, dynamic>?;
    return PaymentModel(
      id: json['id'] as int,
      cycleId: json['cycle_id'] as int,
      memberId: json['member_id'] as int,
      groupId: json['group_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'pending',
      penaltyAmount: (json['penalty_amount'] as num? ?? 0).toDouble(),
      memberName: member?['full_name'] as String?,
      memberPhone: member?['phone'] as String?,
      groupName: group?['name'] as String?,
      cycleNumber: cycle?['cycle_number'] as int?,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  bool get isPaid    => status == 'paid';
  bool get isPending => status == 'pending';

  double get totalDue => amount + penaltyAmount;

  String get memberDisplayName => memberName ?? memberPhone ?? 'Member';
}

class GroupMemberModel {
  final int id;
  final int groupId;
  final int memberId;
  final int membershipNo;
  final bool hasWon;
  final bool isActive;
  final String? mandateId;
  final DateTime? joinedAt;
  // Flattened member fields (from eager load)
  final String phone;
  final String? fullName;
  final String kycStatus;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.membershipNo,
    required this.hasWon,
    required this.isActive,
    this.mandateId,
    this.joinedAt,
    required this.phone,
    this.fullName,
    required this.kycStatus,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>? ?? {};
    return GroupMemberModel(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      memberId: json['member_id'] as int,
      membershipNo: json['membership_no'] as int? ?? 0,
      hasWon: json['has_won'] == true || json['has_won'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      mandateId: json['mandate_id'] as String?,
      joinedAt: json['joined_at'] != null ? DateTime.tryParse(json['joined_at']) : null,
      phone: member['phone'] as String? ?? '',
      fullName: member['full_name'] as String?,
      kycStatus: member['kyc_status'] as String? ?? 'pending',
    );
  }

  String get displayName => fullName ?? phone;
  bool get isKycVerified => kycStatus == 'verified';
}

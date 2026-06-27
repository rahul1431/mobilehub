class ProviderModel {
  final int id;
  final String phone;
  final String? fullName;
  final String kycStatus;
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiry;
  final int activeGroups;
  final int totalMembers;
  final DateTime? createdAt;

  const ProviderModel({
    required this.id,
    required this.phone,
    this.fullName,
    required this.kycStatus,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.subscriptionExpiry,
    this.activeGroups = 0,
    this.totalMembers = 0,
    this.createdAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as int,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String?,
      kycStatus: json['kyc_status'] as String? ?? 'pending',
      subscriptionPlan: json['subscription_plan'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.tryParse(json['subscription_expiry'])
          : null,
      activeGroups: json['active_groups'] as int? ?? 0,
      totalMembers: json['total_members'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  String get displayName => fullName ?? phone;

  bool get isKycVerified => kycStatus == 'verified';

  bool get hasActiveSubscription =>
      subscriptionStatus == 'active' &&
      (subscriptionExpiry == null || subscriptionExpiry!.isAfter(DateTime.now()));
}

class ProfileModel {
  final int id;
  final String phone;
  final String? fullName;
  final String role;
  final String kycStatus;
  final String? preferredLang;
  final String? referralCode;
  final String? fcmToken;

  ProfileModel({
    required this.id,
    required this.phone,
    this.fullName,
    required this.role,
    required this.kycStatus,
    this.preferredLang,
    this.referralCode,
    this.fcmToken,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      phone: json['phone'],
      fullName: json['full_name'],
      role: json['role'] ?? 'chit_member',
      kycStatus: json['kyc_status'] ?? 'pending',
      preferredLang: json['preferred_lang'],
      referralCode: json['referral_code'],
      fcmToken: json['fcm_token'],
    );
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isProvider   => role == 'chit_provider';
  bool get isMember     => role == 'chit_member';
  bool get isKycDone    => kycStatus == 'verified';

  String get displayName => fullName ?? phone;
}

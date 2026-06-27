class ChitPackageModel {
  final int id;
  final String name;
  final double monthlyAmount;
  final int durationMonths;
  final int maxMembers;
  final double commissionPct;
  final bool isActive;
  final String? createdByName;
  final DateTime? createdAt;

  const ChitPackageModel({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.durationMonths,
    required this.maxMembers,
    required this.commissionPct,
    required this.isActive,
    this.createdByName,
    this.createdAt,
  });

  factory ChitPackageModel.fromJson(Map<String, dynamic> json) {
    return ChitPackageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      monthlyAmount: (json['monthly_amount'] as num).toDouble(),
      durationMonths: json['duration_months'] as int,
      maxMembers: json['max_members'] as int,
      commissionPct: (json['commission_pct'] as num).toDouble(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdByName: json['created_by_name'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'monthly_amount': monthlyAmount,
    'duration_months': durationMonths,
    'max_members': maxMembers,
    'commission_pct': commissionPct,
    'is_active': isActive,
  };

  double get totalPot => monthlyAmount * maxMembers;
  double get commissionPerCycle => totalPot * commissionPct / 100;
  double get memberNetPayout => totalPot - commissionPerCycle;

  ChitPackageModel copyWith({
    String? name,
    double? monthlyAmount,
    int? durationMonths,
    int? maxMembers,
    double? commissionPct,
    bool? isActive,
  }) {
    return ChitPackageModel(
      id: id,
      name: name ?? this.name,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      durationMonths: durationMonths ?? this.durationMonths,
      maxMembers: maxMembers ?? this.maxMembers,
      commissionPct: commissionPct ?? this.commissionPct,
      isActive: isActive ?? this.isActive,
      createdByName: createdByName,
      createdAt: createdAt,
    );
  }
}

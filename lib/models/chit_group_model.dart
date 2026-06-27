import 'chit_package_model.dart';

class ChitGroupModel {
  final int id;
  final int packageId;
  final int providerId;
  final String name;
  final String status; // forming, active, completed, cancelled
  final int currentCycle;
  final DateTime? startDate;
  final int totalMembers;
  final int? membershipsCount;
  final ChitPackageModel? package;
  final DateTime? createdAt;

  const ChitGroupModel({
    required this.id,
    required this.packageId,
    required this.providerId,
    required this.name,
    required this.status,
    required this.currentCycle,
    this.startDate,
    required this.totalMembers,
    this.membershipsCount,
    this.package,
    this.createdAt,
  });

  factory ChitGroupModel.fromJson(Map<String, dynamic> json) {
    return ChitGroupModel(
      id: json['id'] as int,
      packageId: json['package_id'] as int,
      providerId: json['provider_id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'forming',
      currentCycle: json['current_cycle'] as int? ?? 0,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      totalMembers: json['total_members'] as int? ?? 0,
      membershipsCount: json['memberships_count'] as int?,
      package: json['package'] != null
          ? ChitPackageModel.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  bool get isForming   => status == 'forming';
  bool get isActive    => status == 'active';
  bool get isCompleted => status == 'completed';

  int get slotsLeft => totalMembers - (membershipsCount ?? 0);

  double get fillPct =>
      totalMembers > 0 ? (membershipsCount ?? 0) / totalMembers : 0.0;

  String get statusLabel {
    switch (status) {
      case 'forming':   return 'Forming';
      case 'active':    return 'Active';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default:          return status;
    }
  }
}

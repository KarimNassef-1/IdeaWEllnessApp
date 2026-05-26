class SubscribedClass {
  const SubscribedClass({
    required this.memberPackageId,
    required this.className,
    this.packageType,
    this.homeBranchName,
    this.remainingSessions,
    this.totalSessions,
    this.validToDate,
  });

  final String memberPackageId;
  final String className;
  final String? packageType;
  final String? homeBranchName;
  final int? remainingSessions;
  final int? totalSessions;
  final String? validToDate;

  String get sessionsLabel {
    if (remainingSessions == null && totalSessions == null) {
      return 'Active';
    }
    if (remainingSessions != null && totalSessions != null) {
      return '$remainingSessions / $totalSessions sessions';
    }
    return '$remainingSessions sessions left';
  }

  factory SubscribedClass.fromJson(Map<String, dynamic> json) {
    return SubscribedClass(
      memberPackageId: json['memberPackageId'] as String? ?? '',
      className: json['className'] as String? ?? '',
      packageType: json['packageType'] as String?,
      homeBranchName: json['homeBranchName'] as String?,
      remainingSessions: json['remainingSessions'] as int?,
      totalSessions: json['totalSessions'] as int?,
      validToDate: json['validToDate'] as String?,
    );
  }
}

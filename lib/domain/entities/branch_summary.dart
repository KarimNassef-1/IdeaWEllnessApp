class BranchSummary {
  const BranchSummary({
    required this.branchId,
    required this.branchCode,
    required this.branchName,
    this.city,
    this.addressLine1,
    this.capacity,
    this.currentlyPresent = 0,
    this.isHomeBranch = false,
    this.crossBranchVisitsRemaining,
  });

  final String branchId;
  final String branchCode;
  final String branchName;
  final String? city;
  final String? addressLine1;
  final int? capacity;
  final int currentlyPresent;
  final bool isHomeBranch;
  final int? crossBranchVisitsRemaining;

  /// 0.0–1.0, or null when no capacity is configured.
  double? get occupancyRatio =>
      (capacity != null && capacity! > 0) ? (currentlyPresent / capacity!).clamp(0.0, 1.0) : null;

  /// Whole percentage 0–100, or null when no capacity is configured.
  int? get occupancyPercent =>
      occupancyRatio == null ? null : (occupancyRatio! * 100).round();

  String get displayLocation {
    final parts = [city, addressLine1]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();
    return parts.isEmpty ? branchCode : parts.join(' - ');
  }

  factory BranchSummary.fromJson(Map<String, dynamic> json) {
    return BranchSummary(
      branchId: json['branchId'] as String? ?? '',
      branchCode: json['branchCode'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      city: json['city'] as String?,
      addressLine1: json['addressLine1'] as String?,
      capacity: json['capacity'] as int?,
      currentlyPresent: json['currentlyPresent'] as int? ?? 0,
      isHomeBranch: json['isHomeBranch'] as bool? ?? false,
      crossBranchVisitsRemaining: json['crossBranchVisitsRemaining'] as int?,
    );
  }
}

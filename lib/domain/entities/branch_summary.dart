class BranchSummary {
  const BranchSummary({
    required this.branchId,
    required this.branchCode,
    required this.branchName,
    this.city,
    this.addressLine1,
  });

  final String branchId;
  final String branchCode;
  final String branchName;
  final String? city;
  final String? addressLine1;

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
    );
  }
}

class MemberPartnership {
  const MemberPartnership({
    required this.partnershipId,
    required this.name,
    this.description,
    this.logoImageUrl,
    this.discountPercentage,
  });

  final String partnershipId;
  final String name;
  final String? description;
  final String? logoImageUrl;
  final double? discountPercentage;

  factory MemberPartnership.fromJson(Map<String, dynamic> json) {
    return MemberPartnership(
      partnershipId:     json['partnershipId']     as String? ?? '',
      name:              json['name']              as String? ?? '',
      description:       json['description']       as String?,
      logoImageUrl:      json['logoImageUrl']       as String?,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }
}

class MemberPackageItem {
  const MemberPackageItem({
    required this.memberPackageId,
    required this.packageName,
    required this.status,
    required this.validFromDate,
    this.packageTypeCode,
    this.packageTypeName,
    this.homeBranchName,
    this.validToDate,
    this.sessionCountOriginal,
    this.sessionCountRemaining,
    this.invitationsTotal,
    this.invitationsRemaining,
    this.ptSessionsTotal,
    this.ptSessionsRemaining,
    this.inBodyTotal,
    this.inBodyRemaining,
    this.freezeAllowanceDays,
    this.freezeRemainingDays,
    this.isFrozen = false,
    this.frozenUntilDate,
    this.linkedClassName,
    this.linkedClassDay,
    this.linkedClassTime,
  });

  final String memberPackageId;
  final String packageName;
  final String? packageTypeCode;
  final String? packageTypeName;
  final String status;
  final String? homeBranchName;
  final String validFromDate;
  final String? validToDate;
  final int? sessionCountOriginal;
  final int? sessionCountRemaining;
  final int? invitationsTotal;
  final int? invitationsRemaining;
  final int? ptSessionsTotal;
  final int? ptSessionsRemaining;
  final int? inBodyTotal;
  final int? inBodyRemaining;
  final int? freezeAllowanceDays;
  final int? freezeRemainingDays;
  final bool isFrozen;
  final String? frozenUntilDate;
  final String? linkedClassName;
  final String? linkedClassDay;
  final String? linkedClassTime;

  bool get hasPerks =>
      (invitationsRemaining ?? 0) > 0 ||
      (ptSessionsRemaining ?? 0) > 0 ||
      (inBodyRemaining ?? 0) > 0 ||
      (freezeRemainingDays ?? 0) > 0;

  bool get isClassPackage => (packageTypeCode ?? '').toUpperCase().contains('CLASS');

  factory MemberPackageItem.fromJson(Map<String, dynamic> json) {
    return MemberPackageItem(
      memberPackageId:       json['memberPackageId'] as String? ?? '',
      packageName:           json['packageName']     as String? ?? '',
      packageTypeCode:       json['packageTypeCode'] as String?,
      packageTypeName:       json['packageTypeName'] as String?,
      status:                json['status']          as String? ?? 'ACTIVE',
      homeBranchName:        json['homeBranchName']  as String?,
      validFromDate:         json['validFromDate']   as String? ?? '',
      validToDate:           json['validToDate']     as String?,
      sessionCountOriginal:  json['sessionCountOriginal']  as int?,
      sessionCountRemaining: json['sessionCountRemaining'] as int?,
      invitationsTotal:      json['invitationsTotal']      as int?,
      invitationsRemaining:  json['invitationsRemaining']  as int?,
      ptSessionsTotal:       json['ptSessionsTotal']       as int?,
      ptSessionsRemaining:   json['ptSessionsRemaining']   as int?,
      inBodyTotal:           json['inBodyTotal']           as int?,
      inBodyRemaining:       json['inBodyRemaining']       as int?,
      freezeAllowanceDays:   json['freezeAllowanceDays']   as int?,
      freezeRemainingDays:   json['freezeRemainingDays']   as int?,
      isFrozen:              json['isFrozen']              as bool?  ?? false,
      frozenUntilDate:       json['frozenUntilDate']       as String?,
      linkedClassName:       json['linkedClassName']       as String?,
      linkedClassDay:        json['linkedClassDay']        as String?,
      linkedClassTime:       json['linkedClassTime']       as String?,
    );
  }
}

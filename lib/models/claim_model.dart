/// Represents a claim request made by an owner for a found item
class ClaimModel {
  final String id;
  final String lostItemId;
  final String foundItemId;
  final String claimantId; // User ID of person claiming
  final String claimCode;
  final String status; // pending, verified, rejected, expired
  final Map<String, String> verificationAnswers; // color, brand, contents
  final String? verifiedBy; // Officer user ID
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const ClaimModel({
    required this.id,
    required this.lostItemId,
    required this.foundItemId,
    required this.claimantId,
    required this.claimCode,
    required this.status,
    required this.verificationAnswers,
    this.verifiedBy,
    this.rejectionReason,
    required this.createdAt,
    this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lostItemId': lostItemId,
      'foundItemId': foundItemId,
      'claimantId': claimantId,
      'claimCode': claimCode,
      'status': status,
      'verificationAnswers': verificationAnswers,
      'verifiedBy': verifiedBy,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory ClaimModel.fromMap(Map<String, dynamic> map) {
    return ClaimModel(
      id: map['id'] ?? '',
      lostItemId: map['lostItemId'] ?? '',
      foundItemId: map['foundItemId'] ?? '',
      claimantId: map['claimantId'] ?? '',
      claimCode: map['claimCode'] ?? '',
      status: map['status'] ?? 'pending',
      verificationAnswers:
          Map<String, String>.from(map['verificationAnswers'] ?? {}),
      verifiedBy: map['verifiedBy'],
      rejectionReason: map['rejectionReason'],
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.parse(map['verifiedAt'])
          : null,
    );
  }

  ClaimModel copyWith({
    String? status,
    String? verifiedBy,
    String? rejectionReason,
    DateTime? verifiedAt,
  }) {
    return ClaimModel(
      id: id,
      lostItemId: lostItemId,
      foundItemId: foundItemId,
      claimantId: claimantId,
      claimCode: claimCode,
      status: status ?? this.status,
      verificationAnswers: verificationAnswers,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}

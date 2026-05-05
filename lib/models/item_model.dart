/// Represents a lost or found item in the system
class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String color;
  final String? brand;
  final String? contents; // e.g., "SBI card, driver's license"
  final String transportType;
  final String? routeNumber;
  final String? stationName;
  final String? locationDetails; // "Seat 14, upper deck" etc.
  final String status;
  final String reportedBy; // User ID
  final String reporterType; // 'owner' or 'finder'
  final String? foundBy; // Finder user ID
  final String? claimCode;
  final String? matchedItemId; // If this item is matched with another
  final double? matchConfidence;
  final List<String> imageUrls;
  final DateTime reportedAt;
  final DateTime? foundAt;
  final DateTime? matchedAt;
  final DateTime? returnedAt;
  final Map<String, dynamic>? verificationAnswers;

  const ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.color,
    this.brand,
    this.contents,
    required this.transportType,
    this.routeNumber,
    this.stationName,
    this.locationDetails,
    required this.status,
    required this.reportedBy,
    required this.reporterType,
    this.foundBy,
    this.claimCode,
    this.matchedItemId,
    this.matchConfidence,
    this.imageUrls = const [],
    required this.reportedAt,
    this.foundAt,
    this.matchedAt,
    this.returnedAt,
    this.verificationAnswers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color': color,
      'brand': brand,
      'contents': contents,
      'transportType': transportType,
      'routeNumber': routeNumber,
      'stationName': stationName,
      'locationDetails': locationDetails,
      'status': status,
      'reportedBy': reportedBy,
      'reporterType': reporterType,
      'foundBy': foundBy,
      'claimCode': claimCode,
      'matchedItemId': matchedItemId,
      'matchConfidence': matchConfidence,
      'imageUrls': imageUrls,
      'reportedAt': reportedAt.toIso8601String(),
      'foundAt': foundAt?.toIso8601String(),
      'matchedAt': matchedAt?.toIso8601String(),
      'returnedAt': returnedAt?.toIso8601String(),
      'verificationAnswers': verificationAnswers,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      color: map['color'] ?? '',
      brand: map['brand'],
      contents: map['contents'],
      transportType: map['transportType'] ?? '',
      routeNumber: map['routeNumber'],
      stationName: map['stationName'],
      locationDetails: map['locationDetails'],
      status: map['status'] ?? 'reported',
      reportedBy: map['reportedBy'] ?? '',
      reporterType: map['reporterType'] ?? 'owner',
      foundBy: map['foundBy'],
      claimCode: map['claimCode'],
      matchedItemId: map['matchedItemId'],
      matchConfidence: (map['matchConfidence'] as num?)?.toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      reportedAt: DateTime.parse(
          map['reportedAt'] ?? DateTime.now().toIso8601String()),
      foundAt: map['foundAt'] != null ? DateTime.parse(map['foundAt']) : null,
      matchedAt:
          map['matchedAt'] != null ? DateTime.parse(map['matchedAt']) : null,
      returnedAt: map['returnedAt'] != null
          ? DateTime.parse(map['returnedAt'])
          : null,
      verificationAnswers:
          map['verificationAnswers'] as Map<String, dynamic>?,
    );
  }

  ItemModel copyWith({
    String? title,
    String? description,
    String? category,
    String? color,
    String? brand,
    String? contents,
    String? transportType,
    String? routeNumber,
    String? stationName,
    String? locationDetails,
    String? status,
    String? foundBy,
    String? claimCode,
    String? matchedItemId,
    double? matchConfidence,
    List<String>? imageUrls,
    DateTime? foundAt,
    DateTime? matchedAt,
    DateTime? returnedAt,
    Map<String, dynamic>? verificationAnswers,
  }) {
    return ItemModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      contents: contents ?? this.contents,
      transportType: transportType ?? this.transportType,
      routeNumber: routeNumber ?? this.routeNumber,
      stationName: stationName ?? this.stationName,
      locationDetails: locationDetails ?? this.locationDetails,
      status: status ?? this.status,
      reportedBy: reportedBy,
      reporterType: reporterType,
      foundBy: foundBy ?? this.foundBy,
      claimCode: claimCode ?? this.claimCode,
      matchedItemId: matchedItemId ?? this.matchedItemId,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      imageUrls: imageUrls ?? this.imageUrls,
      reportedAt: reportedAt,
      foundAt: foundAt ?? this.foundAt,
      matchedAt: matchedAt ?? this.matchedAt,
      returnedAt: returnedAt ?? this.returnedAt,
      verificationAnswers:
          verificationAnswers ?? this.verificationAnswers,
    );
  }

  /// Whether this is a lost-item report (from owner)
  bool get isLostReport => reporterType == 'owner';

  /// Whether this is a found-item report (from finder)
  bool get isFoundReport => reporterType == 'finder';
}

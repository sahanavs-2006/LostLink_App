/// Represents an audit log entry for accountability
class AuditLog {
  final String id;
  final String action; // e.g., "item_reported", "claim_verified"
  final String performedBy; // User ID
  final String? targetItemId;
  final String? targetUserId;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AuditLog({
    required this.id,
    required this.action,
    required this.performedBy,
    this.targetItemId,
    this.targetUserId,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'performedBy': performedBy,
      'targetItemId': targetItemId,
      'targetUserId': targetUserId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] ?? '',
      action: map['action'] ?? '',
      performedBy: map['performedBy'] ?? '',
      targetItemId: map['targetItemId'],
      targetUserId: map['targetUserId'],
      description: map['description'] ?? '',
      timestamp: DateTime.parse(
          map['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
}

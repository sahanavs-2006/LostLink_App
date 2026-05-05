/// Represents a user in the LostLink system
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // commuter, finder, officer, admin
  final String? stationId;
  final DateTime createdAt;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.stationId,
    required this.createdAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'stationId': stationId,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'commuter',
      stationId: map['stationId'],
      createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? stationId,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      stationId: stationId ?? this.stationId,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

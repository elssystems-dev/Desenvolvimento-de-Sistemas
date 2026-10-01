import 'dart:convert';

class UserModel {
  final String id;
  final String nif;
  final String name;
  final String email;
  final String role;
  final String department;
  final bool isBiometricEnabled;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.nif,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.isBiometricEnabled = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? nif,
    String? name,
    String? email,
    String? role,
    String? department,
    bool? isBiometricEnabled,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nif: nif ?? this.nif,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nif': nif,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'isBiometricEnabled': isBiometricEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return UserModel(
      id: documentId ?? map['id']?.toString() ?? '',
      nif: map['nif']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Colaborador',
      department: map['department']?.toString() ?? 'Geral',
      isBiometricEnabled: map['isBiometricEnabled'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

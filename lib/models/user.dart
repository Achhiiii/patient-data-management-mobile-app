class User {
  final String id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String clinicalIdentifier;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.clinicalIdentifier,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'password_hash': passwordHash,
        'clinical_identifier': clinicalIdentifier,
        'role': role,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        fullName: map['full_name'] as String,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
        clinicalIdentifier: map['clinical_identifier'] as String,
        role: map['role'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}

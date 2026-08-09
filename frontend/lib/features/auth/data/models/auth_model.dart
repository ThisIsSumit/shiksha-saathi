class UserModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String role;
  final String preferredLang;
  final String? avatarUrl;
  final bool isVerified;

  const UserModel({
    required this.id, required this.name, this.phone, this.email,
    required this.role, this.preferredLang = 'hi',
    this.avatarUrl, this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'], name: json['name'], phone: json['phone'],
    email: json['email'], role: json['role'],
    preferredLang: json['preferred_lang'] ?? 'hi',
    avatarUrl: json['avatar_url'], isVerified: json['is_verified'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'email': email,
    'role': role, 'preferred_lang': preferredLang, 'avatar_url': avatarUrl,
  };
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({required this.user, required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    user: UserModel.fromJson(json['user']),
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
  );
}

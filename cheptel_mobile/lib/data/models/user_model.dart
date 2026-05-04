class UserModel {
  final int? id;
  final String username;
  final String role;
  final int? farmId;
  final String? farmName;
  final String? token;

  UserModel({
    this.id,
    required this.username,
    required this.role,
    this.farmId,
    this.farmName,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      farmId: json['farmId'],
      farmName: json['farmName'],
      token: json['token'],
    );
  }
}
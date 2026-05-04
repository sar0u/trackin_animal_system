class LoginResponse {
  final String token;
  final String role;
  final String username;
  final int? farmId;
  final String? farmName;
  final String message;

  LoginResponse({
    required this.token,
    required this.role,
    required this.username,
    this.farmId,
    this.farmName,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      farmId: _parseInt(json['farmId']),
      farmName: json['farmName']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}
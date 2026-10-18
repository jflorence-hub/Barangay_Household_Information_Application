class AuthSession {
  final String token;
  final String? role;

  const AuthSession({required this.token, this.role});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
          'The login response did not include a token.');
    }

    final user = json['user'];
    final role = user is Map ? user['role']?.toString() : null;
    return AuthSession(token: token, role: role);
  }
}

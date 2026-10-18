class AuthSession {
  final String token;
  final String? role;
  final bool mustChangePin;

  const AuthSession({required this.token, this.role, this.mustChangePin = false});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException(
          'The login response did not include a token.');
    }

    final user = json['user'];
    final role = user is Map ? user['role']?.toString() : null;
    final mustChangePin = json['must_change_pin'] == true;
    return AuthSession(token: token, role: role, mustChangePin: mustChangePin);
  }
}

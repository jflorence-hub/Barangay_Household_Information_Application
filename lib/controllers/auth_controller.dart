import '../api.dart';
import '../models/auth_session.dart';

class AuthController {
  Future<AuthSession> login({
    required String identifier,
    required String pin,
  }) async {
    final response = await Api.req(
      'POST',
      '/family/login',
      auth: false,
      body: {'identifier': identifier, 'pin': pin},
    );
    final session = AuthSession.fromJson(response);
    await Api.saveToken(session.token);
    return session;
  }

  /// Change the PIN while logged in. Used after a bulk import sets
  /// must_change_pin = true — the user enters their temp PIN and a new one.
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await Api.req(
      'POST',
      '/family/change-pin',
      body: {
        'current_pin': currentPin,
        'new_pin': newPin,
      },
    );
  }
}

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
}

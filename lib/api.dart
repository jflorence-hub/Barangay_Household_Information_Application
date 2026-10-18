import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Laravel API client. Override the default for a physical phone or a
/// deployed server with --dart-define=API_BASE_URL=https://your-domain/api.
class Api {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api');

  static Future<String?> get token async =>
      (await SharedPreferences.getInstance()).getString('family_token');

  static Future<void> saveToken(String value) async =>
      (await SharedPreferences.getInstance()).setString('family_token', value);

  static Future<void> clearToken() async =>
      (await SharedPreferences.getInstance()).remove('family_token');

  static Future<Map<String, dynamic>> req(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final value = await token;
      if (value != null && value.isNotEmpty) {
        headers['Authorization'] = 'Bearer $value';
      }
    }

    final uri = Uri.parse('$baseUrl$path');
    late http.Response response;
    if (method.toUpperCase() == 'POST') {
      response =
          await http.post(uri, headers: headers, body: jsonEncode(body ?? {}));
    } else if (method.toUpperCase() == 'GET') {
      response = await http.get(uri, headers: headers);
    } else {
      throw ArgumentError.value(
          method, 'method', 'Only GET and POST are supported.');
    }

    Map<String, dynamic> data = {};
    if (response.body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          throw const FormatException('Expected a JSON object from the API.');
        }
      } on FormatException {
        throw Exception(
          'The server returned a non-JSON response (${response.statusCode}). '
          'Check the Laravel API URL and server logs.',
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errors = data['errors'];
      String message = data['message']?.toString() ??
          'Request failed (${response.statusCode}).';
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) message = first.first.toString();
      }
      throw Exception(message);
    }
    return data;
  }
}

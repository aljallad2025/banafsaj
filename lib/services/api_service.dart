import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Central API client for بنفسج ستور.
/// IMPORTANT: Update [baseUrl] if the domain ever changes.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://sir-alanakah.online/api/v1';

  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> _handle(http.Response res) async {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw ApiException('خطأ غير متوقع من الخادم', res.statusCode);
    }
    if (res.statusCode == 401) {
      await clearToken();
      throw ApiException(body['message'] ?? 'يجب تسجيل الدخول', 401);
    }
    if (body['success'] != true) {
      throw ApiException(body['message'] ?? 'حدث خطأ', res.statusCode);
    }
    return body['data'];
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$baseUrl/$path'), headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$baseUrl/$path'), headers: _headers, body: jsonEncode(data)).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$baseUrl/$path'), headers: _headers, body: jsonEncode(data)).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  static Future<dynamic> delete(String path, [Map<String, dynamic>? data]) async {
    final res = await http.delete(Uri.parse('$baseUrl/$path'), headers: _headers, body: data != null ? jsonEncode(data) : null).timeout(const Duration(seconds: 20));
    return _handle(res);
  }
}

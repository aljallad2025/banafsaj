import '../models/customer.dart';
import 'api_service.dart';

class AuthService {
  static Future<Customer> login(String email, String password) async {
    final data = await ApiService.post('auth_login.php', {'email': email, 'password': password});
    await ApiService.saveToken(data['token']);
    return Customer.fromJson(data['customer']);
  }

  static Future<Customer> register({required String firstName, String? lastName, required String email, String? phone, required String password}) async {
    final data = await ApiService.post('auth_register.php', {
      'first_name': firstName, 'last_name': lastName, 'email': email, 'phone': phone, 'password': password,
    });
    await ApiService.saveToken(data['token']);
    return Customer.fromJson(data['customer']);
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  static Future<Map<String, dynamic>> profile() async {
    return await ApiService.get('profile.php');
  }

  static Future<void> updateProfile({required String firstName, String? lastName, String? phone}) async {
    await ApiService.put('profile.php', {'first_name': firstName, 'last_name': lastName, 'phone': phone});
  }
}

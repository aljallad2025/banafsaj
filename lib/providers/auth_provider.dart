import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  Customer? _customer;
  bool _loading = true;

  Customer? get customer => _customer;
  bool get isLoggedIn => ApiService.isLoggedIn && _customer != null;
  bool get loading => _loading;

  Future<void> init() async {
    await ApiService.loadToken();
    if (ApiService.isLoggedIn) {
      try {
        final data = await AuthService.profile();
        _customer = Customer.fromJson(data);
      } catch (_) {
        await ApiService.clearToken();
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _customer = await AuthService.login(email, password);
    notifyListeners();
  }

  Future<void> register({required String firstName, String? lastName, required String email, String? phone, required String password}) async {
    _customer = await AuthService.register(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.logout();
    _customer = null;
    notifyListeners();
  }
}

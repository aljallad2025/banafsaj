import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _subtotal = 0;
  String _subtotalFormatted = '0 ر.س';
  bool _loading = false;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _subtotal;
  String get subtotalFormatted => _subtotalFormatted;
  bool get loading => _loading;
  bool get isEmpty => _items.isEmpty;

  Future<void> refresh() async {
    if (!ApiService.isLoggedIn) { _items = []; notifyListeners(); return; }
    _loading = true;
    notifyListeners();
    try {
      final result = await CartService.get();
      _items = result.items;
      _subtotal = result.subtotal;
      _subtotalFormatted = result.subtotalFormatted;
    } catch (_) {
      // keep previous state on transient errors
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> add(int productId, {int? variantId, int quantity = 1}) async {
    await CartService.add(productId, variantId: variantId, quantity: quantity);
    await refresh();
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    await CartService.updateQuantity(cartItemId, quantity);
    await refresh();
  }

  Future<void> remove(int cartItemId) async {
    await CartService.remove(cartItemId);
    await refresh();
  }

  void clearLocal() {
    _items = [];
    _subtotal = 0;
    _subtotalFormatted = '0 ر.س';
    notifyListeners();
  }
}

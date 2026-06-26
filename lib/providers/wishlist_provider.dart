import 'package:flutter/material.dart';
import '../services/wishlist_service.dart';
import '../services/api_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<WishlistItem> _items = [];
  Set<int> _ids = {};
  bool _loading = false;

  List<WishlistItem> get items => _items;
  bool get loading => _loading;

  bool contains(int productId) => _ids.contains(productId);

  Future<void> refresh() async {
    if (!ApiService.isLoggedIn) { _items = []; _ids = {}; notifyListeners(); return; }
    _loading = true;
    notifyListeners();
    try {
      _items = await WishlistService.list();
      _ids = _items.map((i) => i.id).toSet();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<bool> toggle(int productId) async {
    final inWishlist = await WishlistService.toggle(productId);
    if (inWishlist) {
      _ids.add(productId);
    } else {
      _ids.remove(productId);
      _items.removeWhere((i) => i.id == productId);
    }
    notifyListeners();
    if (inWishlist) await refresh();
    return inWishlist;
  }
}

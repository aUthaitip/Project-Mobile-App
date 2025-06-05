import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, int> _items = {}; // id -> quantity
  final Map<String, MenuItem> _menuItems = {};

  Map<String, int> get items => _items;
  Map<String, MenuItem> get menuItems => _menuItems;

  void addToCart(MenuItem item, int quantity) {
    _menuItems[item.id] = item;
    _items[item.id] = (_items[item.id] ?? 0) + quantity;
    notifyListeners();
  }

  void removeFromCart(String id) {
    if (_items.containsKey(id)) {
      _items.remove(id);
      _menuItems.remove(id);
      notifyListeners();
    }
  }

  void increaseQuantity(String id) {
    _items[id] = (_items[id] ?? 0) + 1;
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    if (_items[id]! > 1) {
      _items[id] = _items[id]! - 1;
    } else {
      removeFromCart(id);
    }
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((id, qty) {
      total += (_menuItems[id]?.price ?? 0) * qty;
    });
    return total;
  }


  int get itemCount {
    int count = 0;
    _items.forEach((_, qty) {
      count += qty;
    });
    return count;
  }

  void clearCart() {
    _items.clear();
    _menuItems.clear();
    notifyListeners();
  }
}

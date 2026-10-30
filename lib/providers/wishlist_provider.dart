import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final Map<int, Product> _items = <int, Product>{};

  List<Product> get items => List<Product>.unmodifiable(_items.values);
  int get count => _items.length;

  bool contains(int productId) => _items.containsKey(productId);

  void toggle(Product product) {
    if (_items.remove(product.id) == null) {
      _items[product.id] = product;
    }
    notifyListeners();
  }
}

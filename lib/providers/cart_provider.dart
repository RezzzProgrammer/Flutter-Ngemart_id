import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

enum CartAddResult { added, limitReached, outOfStock }

@immutable
class CartItem {
  const CartItem({
    required this.product,
    required this.color,
    required this.size,
    required this.quantity,
  });

  final Product product;
  final String color;
  final String size;
  final int quantity;

  String get key => keyFor(product.id, color, size);
  double get total => product.price * quantity;

  static String keyFor(int productId, String color, String size) =>
      '$productId|$color|$size';
}

class CartProvider extends ChangeNotifier {
  static const int maxPerOrder = 5;

  final Map<String, CartItem> _items = <String, CartItem>{};

  List<CartItem> get items => _items.values.toList(growable: false);

  int get totalQuantity =>
      _items.values.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold<double>(0, (sum, item) => sum + item.total);

  /// Adds [quantity] of a variant, capped at [maxPerOrder] and available stock.
  CartAddResult add(
    Product product, {
    required String color,
    required String size,
    int quantity = 1,
  }) {
    if (product.isOutOfStock || quantity <= 0) return CartAddResult.outOfStock;

    final limit = math.min(maxPerOrder, product.stock);
    final key = CartItem.keyFor(product.id, color, size);
    final current = _items[key]?.quantity ?? 0;
    if (current >= limit) return CartAddResult.limitReached;

    _items[key] = CartItem(
      product: product,
      color: color,
      size: size,
      quantity: math.min(current + quantity, limit),
    );
    notifyListeners();
    return CartAddResult.added;
  }

  void remove(String key) {
    if (_items.remove(key) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}

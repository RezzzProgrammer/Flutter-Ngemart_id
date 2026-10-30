import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showCartResult(
  BuildContext context,
  Product product,
  CartAddResult result,
) {
  final message = switch (result) {
    CartAddResult.added => '${product.title} masuk ke keranjang',
    CartAddResult.limitReached =>
      'Batas ${CartProvider.maxPerOrder} per pesanan sudah tercapai',
    CartAddResult.outOfStock => 'Stok produk ini sedang habis',
  };
  showAppSnackBar(context, message);
}

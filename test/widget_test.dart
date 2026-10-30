import 'package:flutter_test/flutter_test.dart';
import 'package:ngemart_id/core/formatters.dart';
import 'package:ngemart_id/models/product_model.dart';
import 'package:ngemart_id/providers/cart_provider.dart';

Product _product({int id = 1, int stock = 3}) => Product(
      id: id,
      title: 'Phone',
      description: '',
      category: 'smartphones',
      price: 10,
      rating: 4,
      stock: stock,
      brand: '',
      thumbnail: 'https://example.com/t.png',
      images: const ['https://example.com/t.png', 'https://example.com/a.png'],
    );

void main() {
  group('Product.fromJson', () {
    test('tolerates missing optional fields', () {
      final product = Product.fromJson(
        const {'id': 7, 'title': 'Mascara', 'price': 9},
      );

      expect(product.id, 7);
      expect(product.price, 9.0);
      expect(product.brand, '');
      expect(product.images, isEmpty);
      expect(product.gallery, isEmpty);
    });

    test('gallery puts thumbnail first and removes duplicates', () {
      expect(_product().gallery, [
        'https://example.com/t.png',
        'https://example.com/a.png',
      ]);
    });
  });

  group('CartProvider', () {
    test('caps quantity at the stock / per-order limit', () {
      final cart = CartProvider();
      final product = _product(stock: 3);

      expect(cart.add(product, color: 'Navy', size: 'M', quantity: 2),
          CartAddResult.added);
      expect(cart.add(product, color: 'Navy', size: 'M', quantity: 2),
          CartAddResult.added);
      expect(cart.totalQuantity, 3);
      expect(cart.add(product, color: 'Navy', size: 'M'),
          CartAddResult.limitReached);
    });

    test('rejects out-of-stock products', () {
      final cart = CartProvider();
      expect(cart.add(_product(stock: 0), color: 'Navy', size: 'M'),
          CartAddResult.outOfStock);
      expect(cart.items, isEmpty);
    });
  });

  group('Formatters', () {
    test('categoryLabel humanises slugs', () {
      expect(Formatters.categoryLabel('mens-shirts'), 'Mens Shirts');
    });

    test('price uses two decimals', () {
      expect(Formatters.price(9.5), '\$9.50');
    });
  });
}

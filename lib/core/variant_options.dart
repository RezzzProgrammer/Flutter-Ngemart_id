import 'package:flutter/material.dart';

@immutable
class ColorVariant {
  const ColorVariant(this.name, this.color);

  final String name;
  final Color color;
}

/// DummyJSON has no variant data, so colour / size options are derived locally.
abstract final class VariantOptions {
  static const List<ColorVariant> colors = [
    ColorVariant('Navy', Color(0xFF215887)),
    ColorVariant('Powder', Color(0xFFB3D4E0)),
    ColorVariant('Sand', Color(0xFFE4DCC3)),
    ColorVariant('Slate', Color(0xFF718096)),
    ColorVariant('Charcoal', Color(0xFF2D3748)),
  ];

  static const Set<String> _apparel = {
    'tops',
    'womens-dresses',
    'mens-shirts',
  };

  static List<String> sizesFor(String category) {
    if (category.contains('shoes')) {
      return const ['39', '40', '41', '42', '43'];
    }
    if (_apparel.contains(category)) {
      return const ['S', 'M', 'L', 'XL'];
    }
    return const ['S', 'M', 'L'];
  }
}

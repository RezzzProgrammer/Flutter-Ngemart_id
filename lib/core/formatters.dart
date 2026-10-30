abstract final class Formatters {
  static String price(double value) => '\$${value.toStringAsFixed(2)}';

  /// "mens-shirts" -> "Mens Shirts"
  static String categoryLabel(String slug) {
    return slug
        .split('-')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

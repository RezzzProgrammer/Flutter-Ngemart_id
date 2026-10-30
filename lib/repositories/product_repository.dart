import 'package:dio/dio.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

const String kAllCategory = 'all';

/// Single source of product data for the UI. Caches category lists and
/// per-category catalogs in memory (small: ~200 lightweight records).
class ProductRepository {
  ProductRepository(this._api);

  final ApiService _api;
  List<String>? _categories;
  final Map<String, List<Product>> _cache = {};

  Future<List<String>> categories({
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final cached = _categories;
    if (!forceRefresh && cached != null) return cached;
    return _categories = await _api.getCategories(cancelToken: cancelToken);
  }

  Future<List<Product>> products({
    String query = '',
    String category = kAllCategory,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) async {
    final q = query.trim();
    if (q.isNotEmpty) {
      return _api.searchProducts(q, cancelToken: cancelToken);
    }

    if (!forceRefresh) {
      final cached = _cache[category];
      if (cached != null) return cached;
    }

    final result = category == kAllCategory
        ? await _api.getProducts(cancelToken: cancelToken)
        : await _api.getProductsByCategory(category, cancelToken: cancelToken);
    return _cache[category] = result;
  }

  void dispose() => _api.dispose();
}

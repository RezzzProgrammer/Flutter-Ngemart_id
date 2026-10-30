import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/app_exception.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

enum LoadStatus { idle, loading, success, empty, error }

/// Catalog state: product list, categories, search and category filtering.
class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;

  List<Product> _products = const [];
  List<String> _categories = const [];
  LoadStatus _status = LoadStatus.idle;
  String? _errorMessage;
  String _selectedCategory = kAllCategory;
  String _query = '';

  CancelToken? _cancelToken;
  int _requestId = 0;
  bool _bootstrapped = false;
  bool _disposed = false;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get query => _query;

  /// Loads categories and the first page of products. Safe to call repeatedly.
  Future<void> bootstrap() {
    if (_bootstrapped) return Future<void>.value();
    _bootstrapped = true;
    return _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait<void>([_loadCategories(), _load()]);
  }

  Future<void> selectCategory(String slug) {
    if (slug == _selectedCategory && _query.isEmpty) {
      return Future<void>.value();
    }
    _selectedCategory = slug;
    _query = '';
    return _load();
  }

  Future<void> search(String rawQuery) {
    final q = rawQuery.trim();
    if (q == _query) return Future<void>.value();
    _query = q;
    if (q.isNotEmpty) _selectedCategory = kAllCategory;
    return _load();
  }

  /// Pull-to-refresh: keeps current items on screen while reloading.
    Future<void> refresh() async {
    await Future.wait<void>([
      _loadCategories(force: true),
      _load(force: true, showLoading: _products.isEmpty),
    ]);
  }

  Future<void> retry() async {
    await Future.wait<void>([
      if (_categories.isEmpty) _loadCategories(force: true),
      _load(force: true),
    ]);
  }

  Future<void> _loadCategories({bool force = false}) async {
    try {
      _categories = await _repository.categories(forceRefresh: force);
      _notify();
    } catch (_) {
      // Non-critical: the "All" pill still works without remote categories.
    }
  }

  Future<void> _load({bool force = false, bool showLoading = true}) async {
    _cancelToken?.cancel();
    final token = _cancelToken = CancelToken();
    final requestId = ++_requestId;

    if (showLoading) {
      _status = LoadStatus.loading;
      _errorMessage = null;
      _notify();
    }

    try {
      final result = await _repository.products(
        query: _query,
        category: _selectedCategory,
        forceRefresh: force,
        cancelToken: token,
      );
      if (requestId != _requestId) return;
      _products = result;
      _status = result.isEmpty ? LoadStatus.empty : LoadStatus.success;
      _errorMessage = null;
    } on AppException catch (e) {
      if (e.isCancelled || requestId != _requestId) return;
      _status = LoadStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      if (requestId != _requestId) return;
      _status = LoadStatus.error;
      _errorMessage = 'Terjadi kesalahan tak terduga.';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    super.dispose();
  }
}

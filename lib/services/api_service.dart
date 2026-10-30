import 'package:dio/dio.dart';

import '../core/app_exception.dart';
import '../models/product_model.dart';

/// Thin HTTP layer over the DummyJSON API. Maps transport errors to [AppException].
class ApiService {
  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {'Accept': 'application/json'},
              ),
            );

  static const String _baseUrl = 'https://dummyjson.com';

  /// Only request the fields the UI needs to keep payloads small.
  static const String _fields =
      'id,title,description,category,price,rating,stock,brand,thumbnail,images';

  final Dio _dio;

  Future<List<Product>> getProducts({CancelToken? cancelToken}) {
    return _fetchProducts('/products', const {}, cancelToken);
  }

  Future<List<Product>> searchProducts(
    String query, {
    CancelToken? cancelToken,
  }) {
    return _fetchProducts('/products/search', {'q': query}, cancelToken);
  }

  Future<List<Product>> getProductsByCategory(
    String slug, {
    CancelToken? cancelToken,
  }) {
    return _fetchProducts(
      '/products/category/${Uri.encodeComponent(slug)}',
      const {},
      cancelToken,
    );
  }

  Future<List<String>> getCategories({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/products/category-list',
        cancelToken: cancelToken,
      );
      return (response.data ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<Product>> _fetchProducts(
    String path,
    Map<String, dynamic> extraQuery,
    CancelToken? cancelToken,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'limit': 200, 'select': _fields, ...extraQuery},
        cancelToken: cancelToken,
      );
      final raw = response.data?['products'];
      if (raw is! List) {
        throw const AppException('Format respons server tidak dikenali.');
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    switch(e.type) {
      case DioExceptionType.cancel:
        return const AppException.cancelled();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('Koneksi terlalu lambat. Coba lagi.');
      case DioExceptionType.connectionError:
        return const AppException('Tidak ada koneksi internet.');
      case DioExceptionType.badResponse:
        return AppException(
          'Server bermasalah (kode ${e.response?.statusCode ?? '-'}).',
        );
      default:
        return const AppException('Terjadi kesalahan tak terduga.');
    }
  }

  void dispose() => _dio.close();
}

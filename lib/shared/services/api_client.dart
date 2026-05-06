import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// عميل API للتواصل مع Flask Backend
class ApiClient {
  static String? _authToken;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  /// تعيين التوكن
  static void setAuthToken(String? token) {
    _authToken = token;
  }

  /// الحصول على التوكن
  static String? get authToken => _authToken;

  /// مسح التوكن
  static void clearAuthToken() {
    _authToken = null;
  }

  /// إنشاء الترويسات
  Map<String, String> _headers({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (EnvConfig.apiKey.isNotEmpty) {
      headers['X-API-Key'] = EnvConfig.apiKey;
    }

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// إنشاء رابط API كامل
  Uri _buildUri(String endpoint, {Map<String, String>? queryParams}) {
    final baseUrl = EnvConfig.apiUrl;
    final url = '$baseUrl$endpoint';
    return Uri.parse(url).replace(queryParameters: queryParams);
  }

  /// طلب GET
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.get(
        _buildUri(endpoint, queryParams: queryParams),
        headers: _headers(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('فشل الاتصال بالخادم: $e');
    }
  }

  /// طلب POST
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.post(
        _buildUri(endpoint),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('فشل الاتصال بالخادم: $e');
    }
  }

  /// طلب PUT
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.put(
        _buildUri(endpoint),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('فشل الاتصال بالخادم: $e');
    }
  }

  /// طلب DELETE
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.delete(
        _buildUri(endpoint),
        headers: _headers(requiresAuth: requiresAuth),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error('فشل الاتصال بالخادم: $e');
    }
  }

  /// معالجة الاستجابة
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic data;

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (_) {
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(data);
    } else if (statusCode == 401) {
      // Clear auth token on unauthorized
      clearAuthToken();
      return ApiResponse.error(
        data?['error'] ?? 'غير مصرح',
        statusCode: statusCode,
        code: data?['code'],
      );
    } else if (statusCode == 403) {
      return ApiResponse.error(
        data?['error'] ?? 'ممنوع',
        statusCode: statusCode,
        code: data?['code'],
      );
    } else if (statusCode == 404) {
      return ApiResponse.error(
        data?['error'] ?? 'غير موجود',
        statusCode: statusCode,
        code: data?['code'],
      );
    } else {
      return ApiResponse.error(
        data?['error'] ?? 'خطأ في الخادم',
        statusCode: statusCode,
        code: data?['code'],
      );
    }
  }
}

/// استجابة API
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;
  final String? code;

  ApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.code,
  });

  factory ApiResponse.success(dynamic data) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error(String error, {int? statusCode, String? code}) {
    return ApiResponse._(
      success: false,
      error: error,
      statusCode: statusCode,
      code: code,
    );
  }

  T? getData<T>() {
    if (data is T) return data as T;
    return null;
  }

  Map<String, dynamic>? get dataAsMap {
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  List<dynamic>? get dataAsList {
    if (data is List) return data;
    return null;
  }
}
import 'package:dio/dio.dart';
import 'package:cliente/core/errors/exceptions.dart';

abstract class ApiClient {
  Future<dynamic> get(String endpoint);
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> data});
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> data});
  Future<dynamic> delete(String endpoint);
}

class ApiClientImpl implements ApiClient {
  final Dio _dio;

  ApiClientImpl({required Dio dio}) : _dio = dio;

  @override
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error: ${e.toString()}');
    }
  }
}

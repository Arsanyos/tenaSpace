import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Raised for any failed call to the TenaSpace backend. [message] is safe to
/// show to the user; it prefers the `{ "error": "..." }` body the Next.js
/// routes return.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Binary payload returned by endpoints that stream media.
typedef ApiBytes = ({Uint8List bytes, String contentType});

/// Thin wrapper over `package:http` scoped to the Next.js origin.
///
/// Keeping this class free of Riverpod makes it trivial to unit test with
/// `MockClient` from `package:http/testing.dart`.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required http.Client httpClient,
    this.timeout = const Duration(seconds: 40),
  }) : _http = httpClient;

  final String baseUrl;
  final Duration timeout;
  final http.Client _http;

  Uri resolve(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _post(path, body, accept: 'application/json');
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('The server returned an unexpected response.');
    }
    return decoded;
  }

  Future<ApiBytes> postForBytes(String path, Map<String, dynamic> body) async {
    final response = await _post(
      path,
      body,
      accept: 'audio/wav, audio/mpeg, audio/flac',
    );
    return (
      bytes: response.bodyBytes,
      contentType: response.headers['content-type'] ?? 'audio/wav',
    );
  }

  Future<http.Response> _post(
    String path,
    Map<String, dynamic> body, {
    required String accept,
  }) async {
    final http.Response response;
    try {
      response = await _http
          .post(
            resolve(path),
            headers: {'Content-Type': 'application/json', 'Accept': accept},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'The TenaSpace server took too long to respond.',
      );
    } on ApiException {
      rethrow;
    } on Exception catch (error) {
      throw ApiException(
        'Could not reach the TenaSpace server at $baseUrl. ($error)',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractError(response),
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  static String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } on FormatException {
      // Not JSON — fall through to the generic message.
    }
    return 'Request failed with HTTP ${response.statusCode}.';
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
    httpClient: ref.watch(httpClientProvider),
  );
});

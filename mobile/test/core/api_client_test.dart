import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tenaspace/core/network/api_client.dart';

void main() {
  ApiClient clientReturning(
    http.Response response, {
    void Function(http.Request)? onRequest,
  }) {
    return ApiClient(
      baseUrl: 'http://tenaspace.test',
      httpClient: MockClient((request) async {
        onRequest?.call(request);
        return response;
      }),
    );
  }

  group('ApiClient.postJson', () {
    test('posts JSON to the resolved path and decodes the body', () async {
      late http.Request captured;
      final client = clientReturning(
        http.Response(jsonEncode({'ok': true}), 200),
        onRequest: (request) => captured = request,
      );

      final body = await client.postJson('/api/wellness-feed', {'goals': []});

      expect(body, {'ok': true});
      expect(
        captured.url.toString(),
        'http://tenaspace.test/api/wellness-feed',
      );
      expect(captured.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(captured.body), {'goals': []});
    });

    test('surfaces the server error message on non-2xx responses', () async {
      final client = clientReturning(
        http.Response(jsonEncode({'error': 'GROQ_API_KEY is missing'}), 503),
      );

      expect(
        () => client.postJson('/api/wellness-feed', {}),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'GROQ_API_KEY is missing')
              .having((e) => e.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('falls back to a generic message for non-JSON errors', () async {
      final client = clientReturning(
        http.Response('<html>Bad gateway</html>', 502),
      );

      expect(
        () => client.postJson('/x', {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Request failed with HTTP 502.',
          ),
        ),
      );
    });

    test('wraps transport failures in a readable ApiException', () async {
      final client = ApiClient(
        baseUrl: 'http://tenaspace.test',
        httpClient: MockClient(
          (_) async => throw http.ClientException('refused'),
        ),
      );

      expect(
        () => client.postJson('/x', {}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Could not reach the TenaSpace server'),
          ),
        ),
      );
    });
  });

  test('postForBytes returns the raw body and content type', () async {
    final client = clientReturning(
      http.Response.bytes(
        [1, 2, 3],
        200,
        headers: {'content-type': 'audio/mpeg'},
      ),
    );

    final result = await client.postForBytes('/api/generate-sound', {
      'prompt': 'x',
    });

    expect(result.bytes, [1, 2, 3]);
    expect(result.contentType, 'audio/mpeg');
  });
}

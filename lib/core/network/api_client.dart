import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// A user-friendly error thrown by [ApiClient] when a request fails.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// Turns any error into a message that is safe to show in the UI.
  static String messageOf(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Please try again.';

  @override
  String toString() => message;
}

/// Thin wrapper around `http` for the TVMaze API.
///
/// It only knows about HTTP and JSON. Turning JSON into models is the
/// repository's job, so this class stays small and easy to test.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const baseUrl = 'https://api.tvmaze.com';
  static const _timeout = Duration(seconds: 15);

  final http.Client _http;

  /// Sends a GET request to [path] and returns the decoded JSON body.
  Future<dynamic> get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    final http.Response response;
    try {
      response = await _http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on http.ClientException {
      // Also covers SocketException on mobile: http wraps it in a ClientException.
      throw const ApiException(
        'No internet connection. Please check your network and try again.',
      );
    }

    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } on FormatException {
          throw const ApiException('The server sent an invalid response.');
        }
      case 404:
        throw const ApiException('Not found.', statusCode: 404);
      case 429:
        throw const ApiException(
          'Too many requests. Please wait a moment and try again.',
          statusCode: 429,
        );
      default:
        throw ApiException(
          'Server error (${response.statusCode}). Please try again later.',
          statusCode: response.statusCode,
        );
    }
  }
}

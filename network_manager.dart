import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'network_config.dart';

enum ConnectionStatus { connected, disconnected, slow }

class NetworkManager {
  static final NetworkManager instance = NetworkManager._init();
  NetworkManager._init();

  // ─── Check Connection ─────────────────────────
  Future<ConnectionStatus> checkConnection() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('https://google.com'))
          .timeout(NetworkConfig.connectionTimeout);
      stopwatch.stop();

      if (response.statusCode == 200) {
        if (stopwatch.elapsedMilliseconds > 3000) {
          return ConnectionStatus.slow;
        }
        return ConnectionStatus.connected;
      }
      return ConnectionStatus.disconnected;
    } catch (e) {
      return ConnectionStatus.disconnected;
    }
  }

  // ─── GET Request ──────────────────────────────
  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http
          .get(
        Uri.parse(url),
        headers: NetworkConfig.headers,
      )
          .timeout(NetworkConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      return {
        'success': false,
        'error': 'No internet connection',
        'statusCode': 0,
      };
    } on HttpException {
      return {
        'success': false,
        'error': 'HTTP error occurred',
        'statusCode': 0,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection timeout',
        'statusCode': 0,
      };
    }
  }

  // ─── POST Request ─────────────────────────────
  Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: NetworkConfig.headers,
        body: json.encode(body),
      )
          .timeout(NetworkConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      return {
        'success': false,
        'error': 'No internet connection',
        'statusCode': 0,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'statusCode': 0,
      };
    }
  }

  // ─── PUT Request ──────────────────────────────
  Future<Map<String, dynamic>> put(
      String url, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
        Uri.parse(url),
        headers: NetworkConfig.headers,
        body: json.encode(body),
      )
          .timeout(NetworkConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'statusCode': 0,
      };
    }
  }

  // ─── DELETE Request ───────────────────────────
  Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await http
          .delete(
        Uri.parse(url),
        headers: NetworkConfig.headers,
      )
          .timeout(NetworkConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'statusCode': 0,
      };
    }
  }

  // ─── Handle Response ──────────────────────────
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return {
          'success': true,
          'data': json.decode(response.body),
          'statusCode': response.statusCode,
        };
      case 400:
        return {
          'success': false,
          'error': 'Bad request',
          'statusCode': 400,
        };
      case 401:
        return {
          'success': false,
          'error': 'Unauthorized',
          'statusCode': 401,
        };
      case 403:
        return {
          'success': false,
          'error': 'Forbidden',
          'statusCode': 403,
        };
      case 404:
        return {
          'success': false,
          'error': 'Not found',
          'statusCode': 404,
        };
      case 500:
        return {
          'success': false,
          'error': 'Server error',
          'statusCode': 500,
        };
      default:
        return {
          'success': false,
          'error': 'Unknown error',
          'statusCode': response.statusCode,
        };
    }
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ErrorMessages {
  ErrorMessages._();

  static String fromResponse(http.Response response, {String fallback = ''}) {
    final body = response.body.trim();
    if (body.isNotEmpty) {
      if (_looksLikeHtml(body)) {
        return clean(fallback.isNotEmpty
            ? fallback
            : 'Server unavailable. Please try again later.');
      }

      try {
        final decoded = json.decode(body);
        final parsed = fromDecodedJson(decoded);
        if (parsed.isNotEmpty) return clean(parsed);
      } catch (_) {
        return clean(fallback.isNotEmpty ? fallback : body);
      }
    }

    return clean(fallback.isNotEmpty ? fallback : 'Something went wrong');
  }

  static String fromDecodedJson(dynamic decoded) {
    if (decoded is Map) {
      for (final key in const [
        'message',
        'Message',
        'error',
        'Error',
        'detail',
        'Detail',
        'description',
        'Description',
        'status',
        'Status',
      ]) {
        final value = decoded[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }

      final errors = decoded['errors'] ?? decoded['Errors'];
      final parsedError = fromDecodedJson(errors);
      if (parsedError.isNotEmpty) return parsedError;

      for (final value in decoded.values) {
        final parsed = fromDecodedJson(value);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    if (decoded is List) {
      for (final value in decoded) {
        final parsed = fromDecodedJson(value);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    if (decoded is String) return decoded.trim();
    return '';
  }

  static String fromException(Object error, {String fallback = ''}) {
    if (error is SocketException) {
      return 'Network error. Please check your connection.';
    }

    final cleaned = clean(error.toString());
    if (_looksLikeHtml(cleaned)) {
      return fallback.isNotEmpty
          ? fallback
          : 'Server unavailable. Please try again later.';
    }

    return cleaned.isNotEmpty
        ? cleaned
        : (fallback.isNotEmpty ? fallback : 'Something went wrong');
  }

  static String clean(String message) {
    var text = message.trim();
    if (text.isEmpty) return '';

    text = text.replaceFirst(RegExp(r'^(Exception|Error):\s*'), '');
    text = text.replaceFirst(RegExp(r'^HTTP\s*'), '');
    text = text.replaceFirst(RegExp(r'^\d{3}\s+[A-Za-z ]+\s*[-:]\s*'), '');
    text = text.replaceFirst(RegExp(r'^\d{3}\s*[-:]\s*'), '');
    text = text.replaceAll(RegExp(r'\s*\(\d{3}\)\s*'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  static bool _looksLikeHtml(String text) {
    final lower = text.toLowerCase();
    return lower.contains('<!doctype html') ||
        lower.contains('<html') ||
        lower.contains('<head') ||
        lower.contains('<body') ||
        lower.contains('server error</title>');
  }
}

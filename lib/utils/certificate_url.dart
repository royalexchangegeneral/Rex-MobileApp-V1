import 'dart:convert';

String certificateUrlFromResponse(String body) {
  dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    decoded = body.trim();
  }
  if (decoded is Map &&
      (decoded['status'] == false || decoded['error'] != null)) {
    return '';
  }
  return _findUrl(decoded);
}

String _findUrl(dynamic value) {
  if (value is String) {
    final text = value.trim();
    final uri = Uri.tryParse(text);
    if (uri == null || text.isEmpty) return '';
    if (uri.hasScheme) {
      return ['http', 'https'].contains(uri.scheme) && uri.host.isNotEmpty
          ? uri.toString()
          : '';
    }
    if (text.startsWith('/') ||
        RegExp(r'^[^\s]+\.(pdf|html?)(\?.*)?$', caseSensitive: false)
            .hasMatch(text)) {
      return Uri.parse('https://eportal.rexinsure.com/')
          .resolve(text)
          .toString();
    }
  }
  if (value is Map) {
    for (final key in [
      'certificate',
      'url',
      'certificate_url',
      'certificateUrl',
      'download_url',
      'downloadUrl',
      'file_url',
      'fileUrl',
      'file',
      'path',
      'data',
      'Data'
    ]) {
      final found = _findUrl(value[key]);
      if (found.isNotEmpty) return found;
    }
    for (final nested in value.values.where((v) => v is Map || v is List)) {
      final found = _findUrl(nested);
      if (found.isNotEmpty) return found;
    }
  }
  if (value is List) {
    for (final item in value) {
      final found = _findUrl(item);
      if (found.isNotEmpty) return found;
    }
  }
  return '';
}

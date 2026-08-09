/// Trusted domains for WebView navigation.
/// Only URLs matching these domains will be allowed to load.
class WebViewSecurity {
  WebViewSecurity._();

  static const List<String> _trustedDomains = [
    'paystack.co',
    'standard.paystack.co',
    'checkout.paystack.com',
    'rexinsure.com',
    'eportaltest.rexinsure.com',
    'eportaltest.rexinsure.com',
  ];

  /// Returns true if the given URL belongs to a trusted domain.
  static bool isTrustedUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      // Allow about:blank and data URIs (used internally by WebView)
      if (uri.scheme == 'about' || uri.scheme == 'data') return true;

      // Only allow HTTPS
      if (uri.scheme != 'https') return false;

      for (final domain in _trustedDomains) {
        if (host == domain || host.endsWith('.$domain')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

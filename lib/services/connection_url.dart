/// Helpers for Unraid base URL editing shared by login and settings.
class ConnectionUrl {
  const ConnectionUrl._();

  /// Build a normalized base URL from domain input and protocol toggle.
  ///
  /// If [domain] already includes `http://` or `https://`, that scheme wins.
  static String buildBaseUrl({
    required String domain,
    required bool useHttps,
  }) {
    final input = domain.trim();
    if (input.isEmpty) {
      return '';
    }
    if (input.startsWith('http://') || input.startsWith('https://')) {
      return _stripTrailingSlash(input);
    }
    final scheme = useHttps ? 'https' : 'http';
    return _stripTrailingSlash('$scheme://$input');
  }

  /// Parse host(+port+path) and whether HTTPS is used.
  static ({String domain, bool useHttps}) parse(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      return (domain: '', useHttps: false);
    }
    final withScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
            ? trimmed
            : 'http://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) {
      return (
        domain: trimmed
            .replaceFirst(RegExp(r'^https?://'), '')
            .replaceFirst(RegExp(r'/$'), ''),
        useHttps: trimmed.startsWith('https://'),
      );
    }
    final buffer = StringBuffer(uri.host);
    if (uri.hasPort && uri.port != 80 && uri.port != 443) {
      buffer.write(':${uri.port}');
    }
    if (uri.path.isNotEmpty && uri.path != '/') {
      buffer.write(uri.path);
    }
    return (domain: buffer.toString(), useHttps: uri.scheme == 'https');
  }

  /// Mask API key for list displays (never show full secret in settings row).
  static String maskApiKey(String apiKey) {
    final value = apiKey.trim();
    if (value.isEmpty) {
      return '';
    }
    if (value.length <= 4) {
      return '••••';
    }
    return '${value.substring(0, 4)}••••';
  }

  static String _stripTrailingSlash(String value) {
    if (value.length > 1 && value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}

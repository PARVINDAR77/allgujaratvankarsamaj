/// Safety guard that throws StateError if any test or network configuration
/// targets a live production domain or IP address.
void enforceTestUrlSafety(String url) {
  if (url.trim().isEmpty) return;
  final uri = Uri.tryParse(url);
  final host = uri?.host.toLowerCase() ?? url.toLowerCase();

  if (host.contains('allgujaratvankarsamaj.com') ||
      host.contains('217.21.94.138')) {
    throw StateError(
      'SECURITY VIOLATION: Automated tests are strictly prohibited from targeting production domains or IPs ($url). Automated test suites must use mocks or an isolated local test environment.'
    );
  }
}

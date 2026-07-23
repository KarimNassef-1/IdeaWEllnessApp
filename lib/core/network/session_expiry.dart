/// Thrown when an authenticated request comes back 401 (token missing,
/// invalid, or expired). Callers should stop processing; the app logs out.
class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'Session expired. Please sign in again.';
}

/// Global hook that lets any layer (repositories, services) signal that the
/// session is no longer valid. The [AuthNotifier] registers [onExpired] so a
/// 401 anywhere drops the session and sends the user back to the login screen.
class SessionExpiry {
  SessionExpiry._();

  static void Function()? onExpired;

  /// Fire the registered handler (no-op if none is registered).
  static void notify() => onExpired?.call();
}

/// Convenience guard: on HTTP 401 it fires the global session-expiry hook and
/// throws [UnauthorizedException] so the calling repository stops. Call it in
/// any authenticated request before the generic error handling.
void throwIfUnauthorized(int statusCode) {
  if (statusCode == 401) {
    SessionExpiry.notify();
    throw const UnauthorizedException();
  }
}

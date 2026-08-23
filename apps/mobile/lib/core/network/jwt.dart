import 'dart:convert';

/// Reads the `sub` claim out of a JWT without verifying its signature —
/// the server already validated the credentials before issuing it, so this
/// is purely "what id did the server say this token is for", used locally
/// to know which user is signed in (`POST /auth/login` returns only
/// tokens, not the user's id).
String? decodeJwtSubject(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final claims = jsonDecode(payload) as Map<String, dynamic>;
    return claims['sub'] as String?;
  } on FormatException {
    return null;
  }
}

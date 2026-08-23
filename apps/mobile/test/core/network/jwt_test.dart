import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/core/network/jwt.dart';

String _fakeJwt(Map<String, dynamic> claims) {
  String segment(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  final header = segment({'alg': 'RS256', 'typ': 'JWT'});
  final payload = segment(claims);
  return '$header.$payload.fake-signature';
}

void main() {
  test('reads the sub claim out of a well-formed token', () {
    final token = _fakeJwt({'sub': 'user-123', 'exp': 9999999999});

    expect(decodeJwtSubject(token), 'user-123');
  });

  test('returns null when the token does not have three segments', () {
    expect(decodeJwtSubject('not-a-jwt'), isNull);
    expect(decodeJwtSubject('two.segments'), isNull);
  });

  test('returns null when the payload segment is not valid base64', () {
    expect(decodeJwtSubject('header.###.signature'), isNull);
  });

  test('returns null when there is no sub claim', () {
    final token = _fakeJwt({'exp': 9999999999});

    expect(decodeJwtSubject(token), isNull);
  });
}

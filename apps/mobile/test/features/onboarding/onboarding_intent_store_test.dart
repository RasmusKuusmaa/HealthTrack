import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/data/secure/secure_key_value_store.dart';
import 'package:healthtrack/features/onboarding/onboarding_intent_store.dart';

class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  late OnboardingIntentStore store;

  setUp(() {
    store = OnboardingIntentStore(_FakeSecureKeyValueStore());
  });

  test('reads null when nothing has been written yet', () async {
    expect(await store.read(), isNull);
  });

  test('round-trips a written intent', () async {
    await store.write(GoalsIntent.buildMuscle);

    expect(await store.read(), GoalsIntent.buildMuscle);
  });

  test('overwrites a previously written intent', () async {
    await store.write(GoalsIntent.loseWeight);
    await store.write(GoalsIntent.justExploring);

    expect(await store.read(), GoalsIntent.justExploring);
  });
}

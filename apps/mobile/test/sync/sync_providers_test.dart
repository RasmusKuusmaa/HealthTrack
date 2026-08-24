import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack/sync/sync_providers.dart';

void main() {
  test(
    'user_profile and weight_entry are registered in the entity registry',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(entityRegistryProvider);

      expect(registry['user_profile'], isNotNull);
      expect(registry['weight_entry'], isNotNull);
    },
  );

  test('appDatabase is a single shared instance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(appDatabaseProvider);
    final second = container.read(appDatabaseProvider);

    expect(first, same(second));
  });
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_providers.dart';
import '../../sync/sync_providers.dart';
import 'user_profile_repository.dart';

part 'profile_providers.g.dart';

@riverpod
Future<UserProfileRepository> userProfileRepository(Ref ref) async {
  return UserProfileRepository(
    db: ref.watch(appDatabaseProvider),
    entityWriter: await ref.watch(entityWriterProvider.future),
    syncEngine: await ref.watch(syncEngineProvider.future),
    userId: await ref.watch(currentUserIdProvider.future),
  );
}

/// The signed-in user's preferred unit system ('metric' or 'imperial'),
/// updating live as the profile changes locally. Null until the profile has
/// ever been loaded.
@riverpod
Stream<String?> currentUnitSystem(Ref ref) {
  final repositoryFuture = ref.watch(userProfileRepositoryProvider.future);
  return Stream.fromFuture(repositoryFuture)
      .asyncExpand((repository) => repository.watch())
      .map((profile) => profile?.unitSystem);
}

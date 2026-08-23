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

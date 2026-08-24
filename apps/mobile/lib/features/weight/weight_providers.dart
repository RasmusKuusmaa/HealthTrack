import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/api_providers.dart';
import '../../sync/sync_providers.dart';
import 'weight_repository.dart';

part 'weight_providers.g.dart';

@riverpod
Future<WeightRepository> weightRepository(Ref ref) async {
  return WeightRepository(
    db: ref.watch(appDatabaseProvider),
    entityWriter: await ref.watch(entityWriterProvider.future),
    userId: await ref.watch(currentUserIdProvider.future),
  );
}

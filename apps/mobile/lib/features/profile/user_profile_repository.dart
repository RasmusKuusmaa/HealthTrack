// ignore_for_file: prefer_initializing_formals
import 'dart:convert';

import '../../data/local/app_database.dart';
import '../../domain/op_type.dart';
import '../../sync/entity_writer.dart';
import '../../sync/sync_engine.dart';

/// Reads and edits the signed-in user's profile — the local `user_profiles`
/// projection, kept up to date by the `user_profile` sync entity. The
/// row's id equals the user's own id (see the comment on the server's
/// `UserProfile.id`).
class UserProfileRepository {
  UserProfileRepository({
    required AppDatabase db,
    required EntityWriter entityWriter,
    required SyncEngine syncEngine,
    required String userId,
  }) : _db = db,
       _entityWriter = entityWriter,
       _syncEngine = syncEngine,
       _userId = userId;

  final AppDatabase _db;
  final EntityWriter _entityWriter;
  final SyncEngine _syncEngine;
  final String _userId;

  /// Returns the local profile, bootstrapping from the server first if this
  /// device has never synced before (e.g. right after signing in for the
  /// first time on this install).
  Future<UserProfile?> ensureLoaded() async {
    final existing = await _read();
    if (existing != null) return existing;

    await _syncEngine.bootstrap();
    return _read();
  }

  Stream<UserProfile?> watch() {
    return (_db.select(
      _db.userProfiles,
    )..where((t) => t.id.equals(_userId))).watchSingleOrNull();
  }

  /// Writes only the given fields — a field-level partial update, per the
  /// op log's payload convention.
  Future<void> update(Map<String, dynamic> fields) async {
    await _entityWriter.writeAndMaterialize(
      entityType: 'user_profile',
      entityId: _userId,
      opType: OpType.update,
      payload: jsonEncode(fields),
    );
  }

  Future<UserProfile?> _read() {
    return (_db.select(
      _db.userProfiles,
    )..where((t) => t.id.equals(_userId))).getSingleOrNull();
  }
}

/// Whether onboarding has collected enough to consider the profile "done".
/// Deliberately excludes `locale` (has a sane server default and isn't
/// asked during onboarding).
bool isOnboardingComplete(UserProfile? profile) {
  return profile != null &&
      profile.birthDate != null &&
      profile.sexAtBirth != null &&
      profile.heightCm != null;
}

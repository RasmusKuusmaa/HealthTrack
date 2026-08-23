import '../../data/secure/secure_key_value_store.dart';

/// The coarse goal a user picked during onboarding. Purely local — nothing
/// server-side models "intent" yet (that's Phase 16's `goal` entity); this
/// only tailors this device's own copy/UI, so it never needs to sync.
enum GoalsIntent { loseWeight, buildMuscle, maintainAndTrack, justExploring }

class OnboardingIntentStore {
  OnboardingIntentStore(this._storage);

  static const _key = 'onboarding_goals_intent';

  final SecureKeyValueStore _storage;

  Future<void> write(GoalsIntent intent) => _storage.write(_key, intent.name);

  Future<GoalsIntent?> read() async {
    final raw = await _storage.read(_key);
    if (raw == null) return null;
    for (final intent in GoalsIntent.values) {
      if (intent.name == raw) return intent;
    }
    return null;
  }
}

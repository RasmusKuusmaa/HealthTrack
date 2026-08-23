import 'entity_materializer.dart';

/// entity_type -> its [EntityMaterializer]. Mirrors the server's registry
/// (`services/api/src/app/sync/registry.py`); each feature registers its own
/// entity type once, at startup.
class EntityRegistry {
  final Map<String, EntityMaterializer> _materializers = {};

  void register(String entityType, EntityMaterializer materializer) {
    if (_materializers.containsKey(entityType)) {
      throw StateError('Entity type "$entityType" is already registered.');
    }
    _materializers[entityType] = materializer;
  }

  EntityMaterializer? operator [](String entityType) => _materializers[entityType];
}

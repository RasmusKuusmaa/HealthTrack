// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OperationsTable extends Operations
    with TableInfo<$OperationsTable, Operation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientOpIdMeta = const VerificationMeta(
    'clientOpId',
  );
  @override
  late final GeneratedColumn<String> clientOpId = GeneratedColumn<String>(
    'client_op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientTsMeta = const VerificationMeta(
    'clientTs',
  );
  @override
  late final GeneratedColumn<DateTime> clientTs = GeneratedColumn<DateTime>(
    'client_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverTsMeta = const VerificationMeta(
    'serverTs',
  );
  @override
  late final GeneratedColumn<DateTime> serverTs = GeneratedColumn<DateTime>(
    'server_ts',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientOpId,
    serverSeq,
    userId,
    entityType,
    entityId,
    opType,
    payload,
    deviceId,
    clientTs,
    serverTs,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Operation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_op_id')) {
      context.handle(
        _clientOpIdMeta,
        clientOpId.isAcceptableOrUnknown(
          data['client_op_id']!,
          _clientOpIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientOpIdMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('client_ts')) {
      context.handle(
        _clientTsMeta,
        clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta),
      );
    } else if (isInserting) {
      context.missing(_clientTsMeta);
    }
    if (data.containsKey('server_ts')) {
      context.handle(
        _serverTsMeta,
        serverTs.isAcceptableOrUnknown(data['server_ts']!, _serverTsMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientOpId};
  @override
  Operation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Operation(
      clientOpId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_op_id'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      clientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_ts'],
      )!,
      serverTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_ts'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $OperationsTable createAlias(String alias) {
    return $OperationsTable(attachedDatabase, alias);
  }
}

class Operation extends DataClass implements Insertable<Operation> {
  final String clientOpId;
  final int? serverSeq;
  final String userId;
  final String entityType;
  final String entityId;
  final String opType;
  final String payload;
  final String deviceId;
  final DateTime clientTs;
  final DateTime? serverTs;
  final bool synced;
  const Operation({
    required this.clientOpId,
    this.serverSeq,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.payload,
    required this.deviceId,
    required this.clientTs,
    this.serverTs,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_op_id'] = Variable<String>(clientOpId);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['op_type'] = Variable<String>(opType);
    map['payload'] = Variable<String>(payload);
    map['device_id'] = Variable<String>(deviceId);
    map['client_ts'] = Variable<DateTime>(clientTs);
    if (!nullToAbsent || serverTs != null) {
      map['server_ts'] = Variable<DateTime>(serverTs);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  OperationsCompanion toCompanion(bool nullToAbsent) {
    return OperationsCompanion(
      clientOpId: Value(clientOpId),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      opType: Value(opType),
      payload: Value(payload),
      deviceId: Value(deviceId),
      clientTs: Value(clientTs),
      serverTs: serverTs == null && nullToAbsent
          ? const Value.absent()
          : Value(serverTs),
      synced: Value(synced),
    );
  }

  factory Operation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Operation(
      clientOpId: serializer.fromJson<String>(json['clientOpId']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      opType: serializer.fromJson<String>(json['opType']),
      payload: serializer.fromJson<String>(json['payload']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      clientTs: serializer.fromJson<DateTime>(json['clientTs']),
      serverTs: serializer.fromJson<DateTime?>(json['serverTs']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientOpId': serializer.toJson<String>(clientOpId),
      'serverSeq': serializer.toJson<int?>(serverSeq),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'opType': serializer.toJson<String>(opType),
      'payload': serializer.toJson<String>(payload),
      'deviceId': serializer.toJson<String>(deviceId),
      'clientTs': serializer.toJson<DateTime>(clientTs),
      'serverTs': serializer.toJson<DateTime?>(serverTs),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  Operation copyWith({
    String? clientOpId,
    Value<int?> serverSeq = const Value.absent(),
    String? userId,
    String? entityType,
    String? entityId,
    String? opType,
    String? payload,
    String? deviceId,
    DateTime? clientTs,
    Value<DateTime?> serverTs = const Value.absent(),
    bool? synced,
  }) => Operation(
    clientOpId: clientOpId ?? this.clientOpId,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    opType: opType ?? this.opType,
    payload: payload ?? this.payload,
    deviceId: deviceId ?? this.deviceId,
    clientTs: clientTs ?? this.clientTs,
    serverTs: serverTs.present ? serverTs.value : this.serverTs,
    synced: synced ?? this.synced,
  );
  Operation copyWithCompanion(OperationsCompanion data) {
    return Operation(
      clientOpId: data.clientOpId.present
          ? data.clientOpId.value
          : this.clientOpId,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payload: data.payload.present ? data.payload.value : this.payload,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      clientTs: data.clientTs.present ? data.clientTs.value : this.clientTs,
      serverTs: data.serverTs.present ? data.serverTs.value : this.serverTs,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Operation(')
          ..write('clientOpId: $clientOpId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('deviceId: $deviceId, ')
          ..write('clientTs: $clientTs, ')
          ..write('serverTs: $serverTs, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientOpId,
    serverSeq,
    userId,
    entityType,
    entityId,
    opType,
    payload,
    deviceId,
    clientTs,
    serverTs,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Operation &&
          other.clientOpId == this.clientOpId &&
          other.serverSeq == this.serverSeq &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.opType == this.opType &&
          other.payload == this.payload &&
          other.deviceId == this.deviceId &&
          other.clientTs == this.clientTs &&
          other.serverTs == this.serverTs &&
          other.synced == this.synced);
}

class OperationsCompanion extends UpdateCompanion<Operation> {
  final Value<String> clientOpId;
  final Value<int?> serverSeq;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> opType;
  final Value<String> payload;
  final Value<String> deviceId;
  final Value<DateTime> clientTs;
  final Value<DateTime?> serverTs;
  final Value<bool> synced;
  final Value<int> rowid;
  const OperationsCompanion({
    this.clientOpId = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payload = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.clientTs = const Value.absent(),
    this.serverTs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationsCompanion.insert({
    required String clientOpId,
    this.serverSeq = const Value.absent(),
    required String userId,
    required String entityType,
    required String entityId,
    required String opType,
    required String payload,
    required String deviceId,
    required DateTime clientTs,
    this.serverTs = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientOpId = Value(clientOpId),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       opType = Value(opType),
       payload = Value(payload),
       deviceId = Value(deviceId),
       clientTs = Value(clientTs);
  static Insertable<Operation> custom({
    Expression<String>? clientOpId,
    Expression<int>? serverSeq,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? opType,
    Expression<String>? payload,
    Expression<String>? deviceId,
    Expression<DateTime>? clientTs,
    Expression<DateTime>? serverTs,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientOpId != null) 'client_op_id': clientOpId,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (opType != null) 'op_type': opType,
      if (payload != null) 'payload': payload,
      if (deviceId != null) 'device_id': deviceId,
      if (clientTs != null) 'client_ts': clientTs,
      if (serverTs != null) 'server_ts': serverTs,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationsCompanion copyWith({
    Value<String>? clientOpId,
    Value<int?>? serverSeq,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? opType,
    Value<String>? payload,
    Value<String>? deviceId,
    Value<DateTime>? clientTs,
    Value<DateTime?>? serverTs,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return OperationsCompanion(
      clientOpId: clientOpId ?? this.clientOpId,
      serverSeq: serverSeq ?? this.serverSeq,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      deviceId: deviceId ?? this.deviceId,
      clientTs: clientTs ?? this.clientTs,
      serverTs: serverTs ?? this.serverTs,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientOpId.present) {
      map['client_op_id'] = Variable<String>(clientOpId.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (clientTs.present) {
      map['client_ts'] = Variable<DateTime>(clientTs.value);
    }
    if (serverTs.present) {
      map['server_ts'] = Variable<DateTime>(serverTs.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsCompanion(')
          ..write('clientOpId: $clientOpId, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('deviceId: $deviceId, ')
          ..write('clientTs: $clientTs, ')
          ..write('serverTs: $serverTs, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityFieldVersionsTable extends EntityFieldVersions
    with TableInfo<$EntityFieldVersionsTable, EntityFieldVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityFieldVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientTsMeta = const VerificationMeta(
    'clientTs',
  );
  @override
  late final GeneratedColumn<DateTime> clientTs = GeneratedColumn<DateTime>(
    'client_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverSeqMeta = const VerificationMeta(
    'serverSeq',
  );
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
    'server_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityId,
    fieldName,
    userId,
    clientTs,
    serverSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_field_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityFieldVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('client_ts')) {
      context.handle(
        _clientTsMeta,
        clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta),
      );
    } else if (isInserting) {
      context.missing(_clientTsMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(
        _serverSeqMeta,
        serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityId, fieldName};
  @override
  EntityFieldVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityFieldVersion(
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      clientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_ts'],
      )!,
      serverSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_seq'],
      ),
    );
  }

  @override
  $EntityFieldVersionsTable createAlias(String alias) {
    return $EntityFieldVersionsTable(attachedDatabase, alias);
  }
}

class EntityFieldVersion extends DataClass
    implements Insertable<EntityFieldVersion> {
  final String entityId;
  final String fieldName;
  final String userId;
  final DateTime clientTs;
  final int? serverSeq;
  const EntityFieldVersion({
    required this.entityId,
    required this.fieldName,
    required this.userId,
    required this.clientTs,
    this.serverSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_id'] = Variable<String>(entityId);
    map['field_name'] = Variable<String>(fieldName);
    map['user_id'] = Variable<String>(userId);
    map['client_ts'] = Variable<DateTime>(clientTs);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  EntityFieldVersionsCompanion toCompanion(bool nullToAbsent) {
    return EntityFieldVersionsCompanion(
      entityId: Value(entityId),
      fieldName: Value(fieldName),
      userId: Value(userId),
      clientTs: Value(clientTs),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory EntityFieldVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityFieldVersion(
      entityId: serializer.fromJson<String>(json['entityId']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      userId: serializer.fromJson<String>(json['userId']),
      clientTs: serializer.fromJson<DateTime>(json['clientTs']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityId': serializer.toJson<String>(entityId),
      'fieldName': serializer.toJson<String>(fieldName),
      'userId': serializer.toJson<String>(userId),
      'clientTs': serializer.toJson<DateTime>(clientTs),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  EntityFieldVersion copyWith({
    String? entityId,
    String? fieldName,
    String? userId,
    DateTime? clientTs,
    Value<int?> serverSeq = const Value.absent(),
  }) => EntityFieldVersion(
    entityId: entityId ?? this.entityId,
    fieldName: fieldName ?? this.fieldName,
    userId: userId ?? this.userId,
    clientTs: clientTs ?? this.clientTs,
    serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
  );
  EntityFieldVersion copyWithCompanion(EntityFieldVersionsCompanion data) {
    return EntityFieldVersion(
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      userId: data.userId.present ? data.userId.value : this.userId,
      clientTs: data.clientTs.present ? data.clientTs.value : this.clientTs,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityFieldVersion(')
          ..write('entityId: $entityId, ')
          ..write('fieldName: $fieldName, ')
          ..write('userId: $userId, ')
          ..write('clientTs: $clientTs, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityId, fieldName, userId, clientTs, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityFieldVersion &&
          other.entityId == this.entityId &&
          other.fieldName == this.fieldName &&
          other.userId == this.userId &&
          other.clientTs == this.clientTs &&
          other.serverSeq == this.serverSeq);
}

class EntityFieldVersionsCompanion extends UpdateCompanion<EntityFieldVersion> {
  final Value<String> entityId;
  final Value<String> fieldName;
  final Value<String> userId;
  final Value<DateTime> clientTs;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const EntityFieldVersionsCompanion({
    this.entityId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.userId = const Value.absent(),
    this.clientTs = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityFieldVersionsCompanion.insert({
    required String entityId,
    required String fieldName,
    required String userId,
    required DateTime clientTs,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityId = Value(entityId),
       fieldName = Value(fieldName),
       userId = Value(userId),
       clientTs = Value(clientTs);
  static Insertable<EntityFieldVersion> custom({
    Expression<String>? entityId,
    Expression<String>? fieldName,
    Expression<String>? userId,
    Expression<DateTime>? clientTs,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityId != null) 'entity_id': entityId,
      if (fieldName != null) 'field_name': fieldName,
      if (userId != null) 'user_id': userId,
      if (clientTs != null) 'client_ts': clientTs,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityFieldVersionsCompanion copyWith({
    Value<String>? entityId,
    Value<String>? fieldName,
    Value<String>? userId,
    Value<DateTime>? clientTs,
    Value<int?>? serverSeq,
    Value<int>? rowid,
  }) {
    return EntityFieldVersionsCompanion(
      entityId: entityId ?? this.entityId,
      fieldName: fieldName ?? this.fieldName,
      userId: userId ?? this.userId,
      clientTs: clientTs ?? this.clientTs,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (clientTs.present) {
      map['client_ts'] = Variable<DateTime>(clientTs.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityFieldVersionsCompanion(')
          ..write('entityId: $entityId, ')
          ..write('fieldName: $fieldName, ')
          ..write('userId: $userId, ')
          ..write('clientTs: $clientTs, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexAtBirthMeta = const VerificationMeta(
    'sexAtBirth',
  );
  @override
  late final GeneratedColumn<String> sexAtBirth = GeneratedColumn<String>(
    'sex_at_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unit_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    displayName,
    birthDate,
    sexAtBirth,
    heightCm,
    timezone,
    locale,
    unitSystem,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('sex_at_birth')) {
      context.handle(
        _sexAtBirthMeta,
        sexAtBirth.isAcceptableOrUnknown(
          data['sex_at_birth']!,
          _sexAtBirthMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('unit_system')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unit_system']!, _unitSystemMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      sexAtBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex_at_birth'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_system'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String userId;
  final String? displayName;
  final DateTime? birthDate;
  final String? sexAtBirth;
  final double? heightCm;
  final String timezone;
  final String locale;
  final String unitSystem;
  final DateTime? deletedAt;
  const UserProfile({
    required this.id,
    required this.userId,
    this.displayName,
    this.birthDate,
    this.sexAtBirth,
    this.heightCm,
    required this.timezone,
    required this.locale,
    required this.unitSystem,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || sexAtBirth != null) {
      map['sex_at_birth'] = Variable<String>(sexAtBirth);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    map['timezone'] = Variable<String>(timezone);
    map['locale'] = Variable<String>(locale);
    map['unit_system'] = Variable<String>(unitSystem);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      sexAtBirth: sexAtBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(sexAtBirth),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      timezone: Value(timezone),
      locale: Value(locale),
      unitSystem: Value(unitSystem),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      sexAtBirth: serializer.fromJson<String?>(json['sexAtBirth']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      timezone: serializer.fromJson<String>(json['timezone']),
      locale: serializer.fromJson<String>(json['locale']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String?>(displayName),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'sexAtBirth': serializer.toJson<String?>(sexAtBirth),
      'heightCm': serializer.toJson<double?>(heightCm),
      'timezone': serializer.toJson<String>(timezone),
      'locale': serializer.toJson<String>(locale),
      'unitSystem': serializer.toJson<String>(unitSystem),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    Value<String?> displayName = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> sexAtBirth = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    String? timezone,
    String? locale,
    String? unitSystem,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    displayName: displayName.present ? displayName.value : this.displayName,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    sexAtBirth: sexAtBirth.present ? sexAtBirth.value : this.sexAtBirth,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    timezone: timezone ?? this.timezone,
    locale: locale ?? this.locale,
    unitSystem: unitSystem ?? this.unitSystem,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sexAtBirth: data.sexAtBirth.present
          ? data.sexAtBirth.value
          : this.sexAtBirth,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      locale: data.locale.present ? data.locale.value : this.locale,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('birthDate: $birthDate, ')
          ..write('sexAtBirth: $sexAtBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('timezone: $timezone, ')
          ..write('locale: $locale, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    displayName,
    birthDate,
    sexAtBirth,
    heightCm,
    timezone,
    locale,
    unitSystem,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.birthDate == this.birthDate &&
          other.sexAtBirth == this.sexAtBirth &&
          other.heightCm == this.heightCm &&
          other.timezone == this.timezone &&
          other.locale == this.locale &&
          other.unitSystem == this.unitSystem &&
          other.deletedAt == this.deletedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> displayName;
  final Value<DateTime?> birthDate;
  final Value<String?> sexAtBirth;
  final Value<double?> heightCm;
  final Value<String> timezone;
  final Value<String> locale;
  final Value<String> unitSystem;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sexAtBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.timezone = const Value.absent(),
    this.locale = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String userId,
    this.displayName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sexAtBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.timezone = const Value.absent(),
    this.locale = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<DateTime>? birthDate,
    Expression<String>? sexAtBirth,
    Expression<double>? heightCm,
    Expression<String>? timezone,
    Expression<String>? locale,
    Expression<String>? unitSystem,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (birthDate != null) 'birth_date': birthDate,
      if (sexAtBirth != null) 'sex_at_birth': sexAtBirth,
      if (heightCm != null) 'height_cm': heightCm,
      if (timezone != null) 'timezone': timezone,
      if (locale != null) 'locale': locale,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? displayName,
    Value<DateTime?>? birthDate,
    Value<String?>? sexAtBirth,
    Value<double?>? heightCm,
    Value<String>? timezone,
    Value<String>? locale,
    Value<String>? unitSystem,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      birthDate: birthDate ?? this.birthDate,
      sexAtBirth: sexAtBirth ?? this.sexAtBirth,
      heightCm: heightCm ?? this.heightCm,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      unitSystem: unitSystem ?? this.unitSystem,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (sexAtBirth.present) {
      map['sex_at_birth'] = Variable<String>(sexAtBirth.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(unitSystem.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('birthDate: $birthDate, ')
          ..write('sexAtBirth: $sexAtBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('timezone: $timezone, ')
          ..write('locale: $locale, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OperationsTable operations = $OperationsTable(this);
  late final $EntityFieldVersionsTable entityFieldVersions =
      $EntityFieldVersionsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    operations,
    entityFieldVersions,
    userProfiles,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$OperationsTableCreateCompanionBuilder = OperationsCompanion Function({
  required String clientOpId,
  Value<int?> serverSeq,
  required String userId,
  required String entityType,
  required String entityId,
  required String opType,
  required String payload,
  required String deviceId,
  required DateTime clientTs,
  Value<DateTime?> serverTs,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$OperationsTableUpdateCompanionBuilder = OperationsCompanion Function({
  Value<String> clientOpId,
  Value<int?> serverSeq,
  Value<String> userId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> opType,
  Value<String> payload,
  Value<String> deviceId,
  Value<DateTime> clientTs,
  Value<DateTime?> serverTs,
  Value<bool> synced,
  Value<int> rowid,
});

class $$OperationsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientOpId => $composableBuilder(
    column: $table.clientOpId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serverTs => $composableBuilder(
    column: $table.serverTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientOpId => $composableBuilder(
    column: $table.clientOpId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serverTs => $composableBuilder(
    column: $table.serverTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTable> {
  $$OperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientOpId => $composableBuilder(
    column: $table.clientOpId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTs =>
      $composableBuilder(column: $table.clientTs, builder: (column) => column);

  GeneratedColumn<DateTime> get serverTs =>
      $composableBuilder(column: $table.serverTs, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$OperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTable,
          Operation,
          $$OperationsTableFilterComposer,
          $$OperationsTableOrderingComposer,
          $$OperationsTableAnnotationComposer,
          $$OperationsTableCreateCompanionBuilder,
          $$OperationsTableUpdateCompanionBuilder,
          (
            Operation,
            BaseReferences<_$AppDatabase, $OperationsTable, Operation>,
          ),
          Operation,
          PrefetchHooks Function()
        > {
  $$OperationsTableTableManager(_$AppDatabase db, $OperationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientOpId = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> clientTs = const Value.absent(),
                Value<DateTime?> serverTs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion(
                clientOpId: clientOpId,
                serverSeq: serverSeq,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                deviceId: deviceId,
                clientTs: clientTs,
                serverTs: serverTs,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientOpId,
                Value<int?> serverSeq = const Value.absent(),
                required String userId,
                required String entityType,
                required String entityId,
                required String opType,
                required String payload,
                required String deviceId,
                required DateTime clientTs,
                Value<DateTime?> serverTs = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsCompanion.insert(
                clientOpId: clientOpId,
                serverSeq: serverSeq,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                opType: opType,
                payload: payload,
                deviceId: deviceId,
                clientTs: clientTs,
                serverTs: serverTs,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTable,
      Operation,
      $$OperationsTableFilterComposer,
      $$OperationsTableOrderingComposer,
      $$OperationsTableAnnotationComposer,
      $$OperationsTableCreateCompanionBuilder,
      $$OperationsTableUpdateCompanionBuilder,
      (Operation, BaseReferences<_$AppDatabase, $OperationsTable, Operation>),
      Operation,
      PrefetchHooks Function()
    >;
typedef $$EntityFieldVersionsTableCreateCompanionBuilder =
    EntityFieldVersionsCompanion Function({
      required String entityId,
      required String fieldName,
      required String userId,
      required DateTime clientTs,
      Value<int?> serverSeq,
      Value<int> rowid,
    });
typedef $$EntityFieldVersionsTableUpdateCompanionBuilder =
    EntityFieldVersionsCompanion Function({
      Value<String> entityId,
      Value<String> fieldName,
      Value<String> userId,
      Value<DateTime> clientTs,
      Value<int?> serverSeq,
      Value<int> rowid,
    });

class $$EntityFieldVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $EntityFieldVersionsTable> {
  $$EntityFieldVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityFieldVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityFieldVersionsTable> {
  $$EntityFieldVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverSeq => $composableBuilder(
    column: $table.serverSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityFieldVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityFieldVersionsTable> {
  $$EntityFieldVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTs =>
      $composableBuilder(column: $table.clientTs, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$EntityFieldVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityFieldVersionsTable,
          EntityFieldVersion,
          $$EntityFieldVersionsTableFilterComposer,
          $$EntityFieldVersionsTableOrderingComposer,
          $$EntityFieldVersionsTableAnnotationComposer,
          $$EntityFieldVersionsTableCreateCompanionBuilder,
          $$EntityFieldVersionsTableUpdateCompanionBuilder,
          (
            EntityFieldVersion,
            BaseReferences<
              _$AppDatabase,
              $EntityFieldVersionsTable,
              EntityFieldVersion
            >,
          ),
          EntityFieldVersion,
          PrefetchHooks Function()
        > {
  $$EntityFieldVersionsTableTableManager(
    _$AppDatabase db,
    $EntityFieldVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityFieldVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityFieldVersionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EntityFieldVersionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityId = const Value.absent(),
                Value<String> fieldName = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> clientTs = const Value.absent(),
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityFieldVersionsCompanion(
                entityId: entityId,
                fieldName: fieldName,
                userId: userId,
                clientTs: clientTs,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityId,
                required String fieldName,
                required String userId,
                required DateTime clientTs,
                Value<int?> serverSeq = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityFieldVersionsCompanion.insert(
                entityId: entityId,
                fieldName: fieldName,
                userId: userId,
                clientTs: clientTs,
                serverSeq: serverSeq,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityFieldVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityFieldVersionsTable,
      EntityFieldVersion,
      $$EntityFieldVersionsTableFilterComposer,
      $$EntityFieldVersionsTableOrderingComposer,
      $$EntityFieldVersionsTableAnnotationComposer,
      $$EntityFieldVersionsTableCreateCompanionBuilder,
      $$EntityFieldVersionsTableUpdateCompanionBuilder,
      (
        EntityFieldVersion,
        BaseReferences<
          _$AppDatabase,
          $EntityFieldVersionsTable,
          EntityFieldVersion
        >,
      ),
      EntityFieldVersion,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String userId,
      Value<String?> displayName,
      Value<DateTime?> birthDate,
      Value<String?> sexAtBirth,
      Value<double?> heightCm,
      Value<String> timezone,
      Value<String> locale,
      Value<String> unitSystem,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> displayName,
      Value<DateTime?> birthDate,
      Value<String?> sexAtBirth,
      Value<double?> heightCm,
      Value<String> timezone,
      Value<String> locale,
      Value<String> unitSystem,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexAtBirth => $composableBuilder(
    column: $table.sexAtBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexAtBirth => $composableBuilder(
    column: $table.sexAtBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get sexAtBirth => $composableBuilder(
    column: $table.sexAtBirth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> sexAtBirth = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                userId: userId,
                displayName: displayName,
                birthDate: birthDate,
                sexAtBirth: sexAtBirth,
                heightCm: heightCm,
                timezone: timezone,
                locale: locale,
                unitSystem: unitSystem,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> displayName = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> sexAtBirth = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                userId: userId,
                displayName: displayName,
                birthDate: birthDate,
                sexAtBirth: sexAtBirth,
                heightCm: heightCm,
                timezone: timezone,
                locale: locale,
                unitSystem: unitSystem,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OperationsTableTableManager get operations =>
      $$OperationsTableTableManager(_db, _db.operations);
  $$EntityFieldVersionsTableTableManager get entityFieldVersions =>
      $$EntityFieldVersionsTableTableManager(_db, _db.entityFieldVersions);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}

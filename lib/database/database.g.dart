// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VideoMetadataTable extends VideoMetadata
    with TableInfo<$VideoMetadataTable, VideoMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideoMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jellyfinIdMeta = const VerificationMeta(
    'jellyfinId',
  );
  @override
  late final GeneratedColumn<String> jellyfinId = GeneratedColumn<String>(
    'jellyfin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imdbIdMeta = const VerificationMeta('imdbId');
  @override
  late final GeneratedColumn<String> imdbId = GeneratedColumn<String>(
    'imdb_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<int> budget = GeneratedColumn<int>(
    'budget',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revenueMeta = const VerificationMeta(
    'revenue',
  );
  @override
  late final GeneratedColumn<int> revenue = GeneratedColumn<int>(
    'revenue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _directorMeta = const VerificationMeta(
    'director',
  );
  @override
  late final GeneratedColumn<String> director = GeneratedColumn<String>(
    'director',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _castMeta = const VerificationMeta('cast');
  @override
  late final GeneratedColumn<String> cast = GeneratedColumn<String>(
    'cast',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _awardsMeta = const VerificationMeta('awards');
  @override
  late final GeneratedColumn<String> awards = GeneratedColumn<String>(
    'awards',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rottenTomatoesScoreMeta =
      const VerificationMeta('rottenTomatoesScore');
  @override
  late final GeneratedColumn<int> rottenTomatoesScore = GeneratedColumn<int>(
    'rotten_tomatoes_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _metacriticScoreMeta = const VerificationMeta(
    'metacriticScore',
  );
  @override
  late final GeneratedColumn<int> metacriticScore = GeneratedColumn<int>(
    'metacritic_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    jellyfinId,
    tmdbId,
    imdbId,
    budget,
    revenue,
    director,
    cast,
    awards,
    rottenTomatoesScore,
    metacriticScore,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'video_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<VideoMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jellyfin_id')) {
      context.handle(
        _jellyfinIdMeta,
        jellyfinId.isAcceptableOrUnknown(data['jellyfin_id']!, _jellyfinIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jellyfinIdMeta);
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    }
    if (data.containsKey('imdb_id')) {
      context.handle(
        _imdbIdMeta,
        imdbId.isAcceptableOrUnknown(data['imdb_id']!, _imdbIdMeta),
      );
    }
    if (data.containsKey('budget')) {
      context.handle(
        _budgetMeta,
        budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta),
      );
    }
    if (data.containsKey('revenue')) {
      context.handle(
        _revenueMeta,
        revenue.isAcceptableOrUnknown(data['revenue']!, _revenueMeta),
      );
    }
    if (data.containsKey('director')) {
      context.handle(
        _directorMeta,
        director.isAcceptableOrUnknown(data['director']!, _directorMeta),
      );
    }
    if (data.containsKey('cast')) {
      context.handle(
        _castMeta,
        cast.isAcceptableOrUnknown(data['cast']!, _castMeta),
      );
    }
    if (data.containsKey('awards')) {
      context.handle(
        _awardsMeta,
        awards.isAcceptableOrUnknown(data['awards']!, _awardsMeta),
      );
    }
    if (data.containsKey('rotten_tomatoes_score')) {
      context.handle(
        _rottenTomatoesScoreMeta,
        rottenTomatoesScore.isAcceptableOrUnknown(
          data['rotten_tomatoes_score']!,
          _rottenTomatoesScoreMeta,
        ),
      );
    }
    if (data.containsKey('metacritic_score')) {
      context.handle(
        _metacriticScoreMeta,
        metacriticScore.isAcceptableOrUnknown(
          data['metacritic_score']!,
          _metacriticScoreMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jellyfinId};
  @override
  VideoMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoMetadataData(
      jellyfinId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jellyfin_id'],
      )!,
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      ),
      imdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imdb_id'],
      ),
      budget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget'],
      )!,
      revenue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revenue'],
      )!,
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      )!,
      cast: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cast'],
      )!,
      awards: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}awards'],
      )!,
      rottenTomatoesScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotten_tomatoes_score'],
      )!,
      metacriticScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metacritic_score'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $VideoMetadataTable createAlias(String alias) {
    return $VideoMetadataTable(attachedDatabase, alias);
  }
}

class VideoMetadataData extends DataClass
    implements Insertable<VideoMetadataData> {
  final String jellyfinId;
  final int? tmdbId;
  final String? imdbId;
  final int budget;
  final int revenue;
  final String director;
  final String cast;
  final String awards;
  final int rottenTomatoesScore;
  final int metacriticScore;
  final DateTime lastUpdated;
  const VideoMetadataData({
    required this.jellyfinId,
    this.tmdbId,
    this.imdbId,
    required this.budget,
    required this.revenue,
    required this.director,
    required this.cast,
    required this.awards,
    required this.rottenTomatoesScore,
    required this.metacriticScore,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jellyfin_id'] = Variable<String>(jellyfinId);
    if (!nullToAbsent || tmdbId != null) {
      map['tmdb_id'] = Variable<int>(tmdbId);
    }
    if (!nullToAbsent || imdbId != null) {
      map['imdb_id'] = Variable<String>(imdbId);
    }
    map['budget'] = Variable<int>(budget);
    map['revenue'] = Variable<int>(revenue);
    map['director'] = Variable<String>(director);
    map['cast'] = Variable<String>(cast);
    map['awards'] = Variable<String>(awards);
    map['rotten_tomatoes_score'] = Variable<int>(rottenTomatoesScore);
    map['metacritic_score'] = Variable<int>(metacriticScore);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  VideoMetadataCompanion toCompanion(bool nullToAbsent) {
    return VideoMetadataCompanion(
      jellyfinId: Value(jellyfinId),
      tmdbId: tmdbId == null && nullToAbsent
          ? const Value.absent()
          : Value(tmdbId),
      imdbId: imdbId == null && nullToAbsent
          ? const Value.absent()
          : Value(imdbId),
      budget: Value(budget),
      revenue: Value(revenue),
      director: Value(director),
      cast: Value(cast),
      awards: Value(awards),
      rottenTomatoesScore: Value(rottenTomatoesScore),
      metacriticScore: Value(metacriticScore),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory VideoMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoMetadataData(
      jellyfinId: serializer.fromJson<String>(json['jellyfinId']),
      tmdbId: serializer.fromJson<int?>(json['tmdbId']),
      imdbId: serializer.fromJson<String?>(json['imdbId']),
      budget: serializer.fromJson<int>(json['budget']),
      revenue: serializer.fromJson<int>(json['revenue']),
      director: serializer.fromJson<String>(json['director']),
      cast: serializer.fromJson<String>(json['cast']),
      awards: serializer.fromJson<String>(json['awards']),
      rottenTomatoesScore: serializer.fromJson<int>(
        json['rottenTomatoesScore'],
      ),
      metacriticScore: serializer.fromJson<int>(json['metacriticScore']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jellyfinId': serializer.toJson<String>(jellyfinId),
      'tmdbId': serializer.toJson<int?>(tmdbId),
      'imdbId': serializer.toJson<String?>(imdbId),
      'budget': serializer.toJson<int>(budget),
      'revenue': serializer.toJson<int>(revenue),
      'director': serializer.toJson<String>(director),
      'cast': serializer.toJson<String>(cast),
      'awards': serializer.toJson<String>(awards),
      'rottenTomatoesScore': serializer.toJson<int>(rottenTomatoesScore),
      'metacriticScore': serializer.toJson<int>(metacriticScore),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  VideoMetadataData copyWith({
    String? jellyfinId,
    Value<int?> tmdbId = const Value.absent(),
    Value<String?> imdbId = const Value.absent(),
    int? budget,
    int? revenue,
    String? director,
    String? cast,
    String? awards,
    int? rottenTomatoesScore,
    int? metacriticScore,
    DateTime? lastUpdated,
  }) => VideoMetadataData(
    jellyfinId: jellyfinId ?? this.jellyfinId,
    tmdbId: tmdbId.present ? tmdbId.value : this.tmdbId,
    imdbId: imdbId.present ? imdbId.value : this.imdbId,
    budget: budget ?? this.budget,
    revenue: revenue ?? this.revenue,
    director: director ?? this.director,
    cast: cast ?? this.cast,
    awards: awards ?? this.awards,
    rottenTomatoesScore: rottenTomatoesScore ?? this.rottenTomatoesScore,
    metacriticScore: metacriticScore ?? this.metacriticScore,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  VideoMetadataData copyWithCompanion(VideoMetadataCompanion data) {
    return VideoMetadataData(
      jellyfinId: data.jellyfinId.present
          ? data.jellyfinId.value
          : this.jellyfinId,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      imdbId: data.imdbId.present ? data.imdbId.value : this.imdbId,
      budget: data.budget.present ? data.budget.value : this.budget,
      revenue: data.revenue.present ? data.revenue.value : this.revenue,
      director: data.director.present ? data.director.value : this.director,
      cast: data.cast.present ? data.cast.value : this.cast,
      awards: data.awards.present ? data.awards.value : this.awards,
      rottenTomatoesScore: data.rottenTomatoesScore.present
          ? data.rottenTomatoesScore.value
          : this.rottenTomatoesScore,
      metacriticScore: data.metacriticScore.present
          ? data.metacriticScore.value
          : this.metacriticScore,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoMetadataData(')
          ..write('jellyfinId: $jellyfinId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('imdbId: $imdbId, ')
          ..write('budget: $budget, ')
          ..write('revenue: $revenue, ')
          ..write('director: $director, ')
          ..write('cast: $cast, ')
          ..write('awards: $awards, ')
          ..write('rottenTomatoesScore: $rottenTomatoesScore, ')
          ..write('metacriticScore: $metacriticScore, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jellyfinId,
    tmdbId,
    imdbId,
    budget,
    revenue,
    director,
    cast,
    awards,
    rottenTomatoesScore,
    metacriticScore,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoMetadataData &&
          other.jellyfinId == this.jellyfinId &&
          other.tmdbId == this.tmdbId &&
          other.imdbId == this.imdbId &&
          other.budget == this.budget &&
          other.revenue == this.revenue &&
          other.director == this.director &&
          other.cast == this.cast &&
          other.awards == this.awards &&
          other.rottenTomatoesScore == this.rottenTomatoesScore &&
          other.metacriticScore == this.metacriticScore &&
          other.lastUpdated == this.lastUpdated);
}

class VideoMetadataCompanion extends UpdateCompanion<VideoMetadataData> {
  final Value<String> jellyfinId;
  final Value<int?> tmdbId;
  final Value<String?> imdbId;
  final Value<int> budget;
  final Value<int> revenue;
  final Value<String> director;
  final Value<String> cast;
  final Value<String> awards;
  final Value<int> rottenTomatoesScore;
  final Value<int> metacriticScore;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const VideoMetadataCompanion({
    this.jellyfinId = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.imdbId = const Value.absent(),
    this.budget = const Value.absent(),
    this.revenue = const Value.absent(),
    this.director = const Value.absent(),
    this.cast = const Value.absent(),
    this.awards = const Value.absent(),
    this.rottenTomatoesScore = const Value.absent(),
    this.metacriticScore = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideoMetadataCompanion.insert({
    required String jellyfinId,
    this.tmdbId = const Value.absent(),
    this.imdbId = const Value.absent(),
    this.budget = const Value.absent(),
    this.revenue = const Value.absent(),
    this.director = const Value.absent(),
    this.cast = const Value.absent(),
    this.awards = const Value.absent(),
    this.rottenTomatoesScore = const Value.absent(),
    this.metacriticScore = const Value.absent(),
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  }) : jellyfinId = Value(jellyfinId),
       lastUpdated = Value(lastUpdated);
  static Insertable<VideoMetadataData> custom({
    Expression<String>? jellyfinId,
    Expression<int>? tmdbId,
    Expression<String>? imdbId,
    Expression<int>? budget,
    Expression<int>? revenue,
    Expression<String>? director,
    Expression<String>? cast,
    Expression<String>? awards,
    Expression<int>? rottenTomatoesScore,
    Expression<int>? metacriticScore,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jellyfinId != null) 'jellyfin_id': jellyfinId,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (imdbId != null) 'imdb_id': imdbId,
      if (budget != null) 'budget': budget,
      if (revenue != null) 'revenue': revenue,
      if (director != null) 'director': director,
      if (cast != null) 'cast': cast,
      if (awards != null) 'awards': awards,
      if (rottenTomatoesScore != null)
        'rotten_tomatoes_score': rottenTomatoesScore,
      if (metacriticScore != null) 'metacritic_score': metacriticScore,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideoMetadataCompanion copyWith({
    Value<String>? jellyfinId,
    Value<int?>? tmdbId,
    Value<String?>? imdbId,
    Value<int>? budget,
    Value<int>? revenue,
    Value<String>? director,
    Value<String>? cast,
    Value<String>? awards,
    Value<int>? rottenTomatoesScore,
    Value<int>? metacriticScore,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return VideoMetadataCompanion(
      jellyfinId: jellyfinId ?? this.jellyfinId,
      tmdbId: tmdbId ?? this.tmdbId,
      imdbId: imdbId ?? this.imdbId,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
      director: director ?? this.director,
      cast: cast ?? this.cast,
      awards: awards ?? this.awards,
      rottenTomatoesScore: rottenTomatoesScore ?? this.rottenTomatoesScore,
      metacriticScore: metacriticScore ?? this.metacriticScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jellyfinId.present) {
      map['jellyfin_id'] = Variable<String>(jellyfinId.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (imdbId.present) {
      map['imdb_id'] = Variable<String>(imdbId.value);
    }
    if (budget.present) {
      map['budget'] = Variable<int>(budget.value);
    }
    if (revenue.present) {
      map['revenue'] = Variable<int>(revenue.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (cast.present) {
      map['cast'] = Variable<String>(cast.value);
    }
    if (awards.present) {
      map['awards'] = Variable<String>(awards.value);
    }
    if (rottenTomatoesScore.present) {
      map['rotten_tomatoes_score'] = Variable<int>(rottenTomatoesScore.value);
    }
    if (metacriticScore.present) {
      map['metacritic_score'] = Variable<int>(metacriticScore.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideoMetadataCompanion(')
          ..write('jellyfinId: $jellyfinId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('imdbId: $imdbId, ')
          ..write('budget: $budget, ')
          ..write('revenue: $revenue, ')
          ..write('director: $director, ')
          ..write('cast: $cast, ')
          ..write('awards: $awards, ')
          ..write('rottenTomatoesScore: $rottenTomatoesScore, ')
          ..write('metacriticScore: $metacriticScore, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideoMetadataTable videoMetadata = $VideoMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [videoMetadata];
}

typedef $$VideoMetadataTableCreateCompanionBuilder =
    VideoMetadataCompanion Function({
      required String jellyfinId,
      Value<int?> tmdbId,
      Value<String?> imdbId,
      Value<int> budget,
      Value<int> revenue,
      Value<String> director,
      Value<String> cast,
      Value<String> awards,
      Value<int> rottenTomatoesScore,
      Value<int> metacriticScore,
      required DateTime lastUpdated,
      Value<int> rowid,
    });
typedef $$VideoMetadataTableUpdateCompanionBuilder =
    VideoMetadataCompanion Function({
      Value<String> jellyfinId,
      Value<int?> tmdbId,
      Value<String?> imdbId,
      Value<int> budget,
      Value<int> revenue,
      Value<String> director,
      Value<String> cast,
      Value<String> awards,
      Value<int> rottenTomatoesScore,
      Value<int> metacriticScore,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$VideoMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $VideoMetadataTable> {
  $$VideoMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get jellyfinId => $composableBuilder(
    column: $table.jellyfinId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imdbId => $composableBuilder(
    column: $table.imdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awards => $composableBuilder(
    column: $table.awards,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rottenTomatoesScore => $composableBuilder(
    column: $table.rottenTomatoesScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metacriticScore => $composableBuilder(
    column: $table.metacriticScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VideoMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $VideoMetadataTable> {
  $$VideoMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get jellyfinId => $composableBuilder(
    column: $table.jellyfinId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imdbId => $composableBuilder(
    column: $table.imdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budget => $composableBuilder(
    column: $table.budget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revenue => $composableBuilder(
    column: $table.revenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cast => $composableBuilder(
    column: $table.cast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awards => $composableBuilder(
    column: $table.awards,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rottenTomatoesScore => $composableBuilder(
    column: $table.rottenTomatoesScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metacriticScore => $composableBuilder(
    column: $table.metacriticScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VideoMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideoMetadataTable> {
  $$VideoMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get jellyfinId => $composableBuilder(
    column: $table.jellyfinId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get imdbId =>
      $composableBuilder(column: $table.imdbId, builder: (column) => column);

  GeneratedColumn<int> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<int> get revenue =>
      $composableBuilder(column: $table.revenue, builder: (column) => column);

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get cast =>
      $composableBuilder(column: $table.cast, builder: (column) => column);

  GeneratedColumn<String> get awards =>
      $composableBuilder(column: $table.awards, builder: (column) => column);

  GeneratedColumn<int> get rottenTomatoesScore => $composableBuilder(
    column: $table.rottenTomatoesScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metacriticScore => $composableBuilder(
    column: $table.metacriticScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$VideoMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VideoMetadataTable,
          VideoMetadataData,
          $$VideoMetadataTableFilterComposer,
          $$VideoMetadataTableOrderingComposer,
          $$VideoMetadataTableAnnotationComposer,
          $$VideoMetadataTableCreateCompanionBuilder,
          $$VideoMetadataTableUpdateCompanionBuilder,
          (
            VideoMetadataData,
            BaseReferences<
              _$AppDatabase,
              $VideoMetadataTable,
              VideoMetadataData
            >,
          ),
          VideoMetadataData,
          PrefetchHooks Function()
        > {
  $$VideoMetadataTableTableManager(_$AppDatabase db, $VideoMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideoMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideoMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideoMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jellyfinId = const Value.absent(),
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> imdbId = const Value.absent(),
                Value<int> budget = const Value.absent(),
                Value<int> revenue = const Value.absent(),
                Value<String> director = const Value.absent(),
                Value<String> cast = const Value.absent(),
                Value<String> awards = const Value.absent(),
                Value<int> rottenTomatoesScore = const Value.absent(),
                Value<int> metacriticScore = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VideoMetadataCompanion(
                jellyfinId: jellyfinId,
                tmdbId: tmdbId,
                imdbId: imdbId,
                budget: budget,
                revenue: revenue,
                director: director,
                cast: cast,
                awards: awards,
                rottenTomatoesScore: rottenTomatoesScore,
                metacriticScore: metacriticScore,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jellyfinId,
                Value<int?> tmdbId = const Value.absent(),
                Value<String?> imdbId = const Value.absent(),
                Value<int> budget = const Value.absent(),
                Value<int> revenue = const Value.absent(),
                Value<String> director = const Value.absent(),
                Value<String> cast = const Value.absent(),
                Value<String> awards = const Value.absent(),
                Value<int> rottenTomatoesScore = const Value.absent(),
                Value<int> metacriticScore = const Value.absent(),
                required DateTime lastUpdated,
                Value<int> rowid = const Value.absent(),
              }) => VideoMetadataCompanion.insert(
                jellyfinId: jellyfinId,
                tmdbId: tmdbId,
                imdbId: imdbId,
                budget: budget,
                revenue: revenue,
                director: director,
                cast: cast,
                awards: awards,
                rottenTomatoesScore: rottenTomatoesScore,
                metacriticScore: metacriticScore,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VideoMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VideoMetadataTable,
      VideoMetadataData,
      $$VideoMetadataTableFilterComposer,
      $$VideoMetadataTableOrderingComposer,
      $$VideoMetadataTableAnnotationComposer,
      $$VideoMetadataTableCreateCompanionBuilder,
      $$VideoMetadataTableUpdateCompanionBuilder,
      (
        VideoMetadataData,
        BaseReferences<_$AppDatabase, $VideoMetadataTable, VideoMetadataData>,
      ),
      VideoMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideoMetadataTableTableManager get videoMetadata =>
      $$VideoMetadataTableTableManager(_db, _db.videoMetadata);
}

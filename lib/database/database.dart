import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class VideoMetadata extends Table {
  TextColumn get jellyfinId => text()();
  IntColumn get tmdbId => integer().nullable()();
  TextColumn get imdbId => text().nullable()();
  IntColumn get budget => integer().withDefault(const Constant(0))();
  IntColumn get revenue => integer().withDefault(const Constant(0))();
  TextColumn get director => text().withDefault(const Constant(''))();
  TextColumn get cast =>
      text().withDefault(const Constant('[]'))(); // JSON encoded list
  TextColumn get awards => text().withDefault(const Constant(''))();
  IntColumn get rottenTomatoesScore =>
      integer().withDefault(const Constant(0))();
  IntColumn get metacriticScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();

  @override
  Set<Column> get primaryKey => {jellyfinId};
}

@DriftDatabase(tables: [VideoMetadata])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<bool> hasMetadata(String jellyfinId) async {
    final result = await (select(
      videoMetadata,
    )..where((t) => t.jellyfinId.equals(jellyfinId))).getSingleOrNull();
    return result != null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

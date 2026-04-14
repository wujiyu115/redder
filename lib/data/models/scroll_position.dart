import 'package:drift/drift.dart';

/// Drift table for storing scroll positions per timeline.
///
/// Each timeline (unified, category, folder, single feed, tag, filter)
/// has its own independent scroll position.
class ScrollPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get timelineId => text()();
  IntColumn get accountId => integer().nullable()();
  IntColumn get lastItemId => integer().nullable()();
  RealColumn get scrollOffset => real().withDefault(const Constant(0.0))();
  DateTimeColumn get savedAt => dateTime()();
}

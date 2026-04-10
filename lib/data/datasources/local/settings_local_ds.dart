import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Local data source for AppSettings using Drift.
///
/// Manages a singleton settings record (id = 0).
/// Provides read/write access to all application settings.
class SettingsLocalDataSource {
  AppDatabase get _db => AppDatabase.instance;

  /// Gets the current settings, creating defaults if none exist.
  Future<AppSettingsTableData> getSettings() async {
    final query = _db.select(_db.appSettingsTable)
      ..where((t) => t.id.equals(0));
    final settings = await query.getSingleOrNull();
    if (settings != null) return settings;

    // Create default settings
    await _db.into(_db.appSettingsTable).insert(
      AppSettingsTableCompanion.insert(
        id: const Value(0),
      ),
    );
    return (await query.getSingle());
  }

  /// Saves the settings (upsert with id = 0).
  Future<void> saveSettings(AppSettingsTableCompanion settings) {
    return _db.into(_db.appSettingsTable).insertOnConflictUpdate(
      settings,
    );
  }

  /// Updates a single setting value using a modifier function.
  ///
  /// The modifier receives the current settings data and returns
  /// a companion with the fields to update.
  Future<AppSettingsTableData> updateSettings(
    AppSettingsTableCompanion Function(AppSettingsTableData current) modifier,
  ) async {
    final current = await getSettings();
    final companion = modifier(current);
    await (_db.update(_db.appSettingsTable)
          ..where((t) => t.id.equals(0)))
        .write(companion);
    return getSettings();
  }

  /// Resets all settings to defaults.
  Future<AppSettingsTableData> resetToDefaults() async {
    await (_db.delete(_db.appSettingsTable)
          ..where((t) => t.id.equals(0)))
        .go();
    return getSettings(); // Will create defaults
  }

  /// Watches settings for changes.
  Stream<AppSettingsTableData> watchSettings() {
    final query = _db.select(_db.appSettingsTable)
      ..where((t) => t.id.equals(0));
    return query.watchSingle();
  }
}

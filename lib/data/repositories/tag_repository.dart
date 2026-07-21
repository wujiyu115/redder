import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/tag.dart';

/// Repository for Tag and TaggedItem operations.
///
/// Manages built-in tags (Later, Bookmarks, Favorites) and
/// user-created custom tags. Handles tag-item associations.
class TagRepository {
  final AppDatabase? _dbOverride;

  TagRepository({AppDatabase? db}) : _dbOverride = db;

  AppDatabase get _db => _dbOverride ?? AppDatabase.instance;

  // ─── Tag CRUD ─────────────────────────────────────────────

  /// Initializes built-in tags (Later, Bookmarks, Favorites) if missing.
  ///
  /// Built-in tags are app-GLOBAL: they are not scoped to any account
  /// (Reader sync uses server-side tags for folders, not these). The
  /// [accountId] parameter is accepted for API stability but ignored —
  /// built-in tags are always queried un-scoped and inserted with
  /// `accountId = null`. Call once at app startup.
  Future<void> initializeBuiltInTags({int? accountId}) async {
    // Built-in tags are global; ignore accountId and query/insert un-scoped.
    final existing = await (_db.select(_db.tags)
          ..where((t) => t.isBuiltIn.equals(true)))
        .get();
    final existingNames = existing.map((t) => t.name).toSet();

    final builtInTags = [
      (TagNames.laterName, 'clock', 0),
      (TagNames.bookmarksName, 'bookmark', 1),
      (TagNames.favoritesName, 'heart', 2),
    ];

    final now = DateTime.now();
    await _db.batch((batch) {
      for (final (name, icon, order) in builtInTags) {
        if (!existingNames.contains(name)) {
          batch.insert(
            _db.tags,
            TagsCompanion.insert(
              name: name,
              iconName: Value(icon),
              isBuiltIn: const Value(true),
              sortOrder: Value(order),
              createdAt: now,
              // accountId intentionally null: built-in tags are global.
            ),
          );
        }
      }
    });
  }

  /// Gets all tags, optionally filtered by [accountId].
  Future<List<Tag>> getAllTags({int? accountId}) {
    final query = _db.select(_db.tags)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets only built-in tags, optionally filtered by [accountId].
  Future<List<Tag>> getBuiltInTags({int? accountId}) {
    final query = _db.select(_db.tags)
      ..where((t) => t.isBuiltIn.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets only custom (user-created) tags, optionally filtered by [accountId].
  Future<List<Tag>> getCustomTags({int? accountId}) {
    final query = _db.select(_db.tags)
      ..where((t) => t.isBuiltIn.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.get();
  }

  /// Gets a tag by its ID.
  Future<Tag?> getTagById(int id, {int? accountId}) {
    final query = _db.select(_db.tags)..where((t) => t.id.equals(id));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.getSingleOrNull();
  }

  /// Gets a tag by its name, optionally scoped to [accountId].
  ///
  /// Defensive against duplicate rows: returns the first match (if any)
  /// rather than throwing when multiple rows share the same name.
  Future<Tag?> getTagByName(String name, {int? accountId}) async {
    final query = _db.select(_db.tags)..where((t) => t.name.equals(name));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    final result = await (query..limit(1)).get();
    return result.isEmpty ? null : result.first;
  }

  /// Creates a new custom tag, optionally associated with [accountId].
  Future<Tag> createTag({
    required String name,
    String? iconName,
    int? accountId,
  }) async {
    final allTags = await getAllTags(accountId: accountId);
    final sortOrder = allTags.isEmpty ? 0 : allTags.last.sortOrder + 1;

    final id = await _db.into(_db.tags).insert(
      TagsCompanion.insert(
        name: name,
        iconName: Value(iconName),
        isBuiltIn: const Value(false),
        sortOrder: Value(sortOrder),
        createdAt: DateTime.now(),
      ).copyWith(accountId: Value(accountId)),
    );

    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Updates a tag.
  Future<void> updateTag(Tag tag) {
    return (_db.update(_db.tags)..where((t) => t.id.equals(tag.id)))
        .write(TagsCompanion(
      name: Value(tag.name),
      iconName: Value(tag.iconName),
      isShared: Value(tag.isShared),
      sharedFeedUrl: Value(tag.sharedFeedUrl),
      itemCount: Value(tag.itemCount),
      sortOrder: Value(tag.sortOrder),
    ));
  }

  /// Deletes a custom tag and all its associations.
  ///
  /// Built-in tags cannot be deleted.
  Future<bool> deleteTag(int tagId) async {
    final tag = await getTagById(tagId);
    if (tag == null || tag.isBuiltIn) return false;

    await _db.transaction(() async {
      // Delete all tagged item associations
      await (_db.delete(_db.taggedItems)
            ..where((t) => t.tagId.equals(tagId)))
          .go();

      // Delete the tag
      await (_db.delete(_db.tags)..where((t) => t.id.equals(tagId))).go();
    });

    return true;
  }

  // ─── Tag-Item Associations ────────────────────────────────

  /// Tags an item with a specific tag, optionally associated with [accountId].
  Future<void> tagItem(int tagId, int itemId, {int? accountId}) async {
    // Check if already tagged
    final existing = await (_db.select(_db.taggedItems)
          ..where((t) => t.tagId.equals(tagId) & t.itemId.equals(itemId)))
        .getSingleOrNull();

    if (existing != null) return; // Already tagged

    await _db.transaction(() async {
      await _db.into(_db.taggedItems).insert(
        TaggedItemsCompanion.insert(
          tagId: tagId,
          itemId: itemId,
          taggedAt: DateTime.now(),
        ).copyWith(accountId: Value(accountId)),
      );

      // Update tag item count
      final tag = await getTagById(tagId);
      if (tag != null) {
        await (_db.update(_db.tags)..where((t) => t.id.equals(tagId)))
            .write(TagsCompanion(itemCount: Value(tag.itemCount + 1)));
      }
    });
  }

  /// Removes a tag from an item.
  Future<void> untagItem(int tagId, int itemId) async {
    final existing = await (_db.select(_db.taggedItems)
          ..where((t) => t.tagId.equals(tagId) & t.itemId.equals(itemId)))
        .getSingleOrNull();

    if (existing == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.taggedItems)
            ..where((t) => t.id.equals(existing.id)))
          .go();

      // Update tag item count
      final tag = await getTagById(tagId);
      if (tag != null) {
        await (_db.update(_db.tags)..where((t) => t.id.equals(tagId)))
            .write(TagsCompanion(
          itemCount: Value((tag.itemCount - 1).clamp(0, tag.itemCount)),
        ));
      }
    });
  }
  /// Toggles a tag on an item (add if not tagged, remove if tagged).
  Future<bool> toggleTag(int tagId, int itemId) async {
    final isTagged = await isItemTagged(tagId, itemId);
    if (isTagged) {
      await untagItem(tagId, itemId);
      return false;
    } else {
      await tagItem(tagId, itemId);
      return true;
    }
  }

  /// Checks if an item has a specific tag.
  Future<bool> isItemTagged(int tagId, int itemId) async {
    final existing = await (_db.select(_db.taggedItems)
          ..where((t) => t.tagId.equals(tagId) & t.itemId.equals(itemId)))
        .getSingleOrNull();
    return existing != null;
  }

  /// Gets all item IDs with a specific tag, optionally filtered by [accountId].
  Future<List<int>> getItemIdsByTag(int tagId, {int? accountId}) async {
    final query = _db.select(_db.taggedItems)
      ..where((t) => t.tagId.equals(tagId));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    final items = await query.get();
    return items.map((ti) => ti.itemId).toList();
  }

  /// Gets all tag IDs for a specific item, optionally filtered by [accountId].
  Future<List<int>> getTagIdsForItem(int itemId, {int? accountId}) async {
    final query = _db.select(_db.taggedItems)
      ..where((t) => t.itemId.equals(itemId));
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    final items = await query.get();
    return items.map((ti) => ti.tagId).toList();
  }

  /// Gets the item count for a tag, optionally filtered by [accountId].
  Future<int> getTagItemCount(int tagId, {int? accountId}) async {
    final countExp = _db.taggedItems.id.count();
    final query = _db.selectOnly(_db.taggedItems)
      ..addColumns([countExp])
      ..where(_db.taggedItems.tagId.equals(tagId));
    if (accountId != null) {
      query.where(_db.taggedItems.accountId.equals(accountId));
    }
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Removes all tag associations for an item.
  Future<void> removeAllTagsForItem(int itemId) async {
    await _db.transaction(() async {
      final taggedItems = await (_db.select(_db.taggedItems)
            ..where((t) => t.itemId.equals(itemId)))
          .get();

      for (final ti in taggedItems) {
        // Update tag counts
        final tag = await getTagById(ti.tagId);
        if (tag != null) {
          await (_db.update(_db.tags)..where((t) => t.id.equals(ti.tagId)))
              .write(TagsCompanion(
            itemCount: Value((tag.itemCount - 1).clamp(0, tag.itemCount)),
          ));
        }
      }

      await (_db.delete(_db.taggedItems)
            ..where((t) => t.itemId.equals(itemId)))
          .go();
    });
  }

  /// Watches all tags for changes, optionally filtered by [accountId].
  Stream<List<Tag>> watchAllTags({int? accountId}) {
    final query = _db.select(_db.tags)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    return query.watch();
  }

  // ─── Built-in Tag Helpers ─────────────────────────────────
  //
  // Built-in tags (Later/Bookmarks/Favorites) are app-global — they are not
  // scoped to a sync account (Reader sync uses server-side tags for folders,
  // not these). The [accountId] param is accepted for backward-compat with
  // callers that pass one, but is ignored; lookups are always unscoped so the
  // tag resolves under any active account.

  /// Gets the "Later" built-in tag (app-global; [accountId] ignored).
  Future<Tag?> getLaterTag({int? accountId}) => getTagByName(TagNames.laterName);

  /// Gets the "Bookmarks" built-in tag (app-global; [accountId] ignored).
  Future<Tag?> getBookmarksTag({int? accountId}) => getTagByName(TagNames.bookmarksName);

  /// Gets the "Favorites" built-in tag (app-global; [accountId] ignored).
  Future<Tag?> getFavoritesTag({int? accountId}) => getTagByName(TagNames.favoritesName);
}

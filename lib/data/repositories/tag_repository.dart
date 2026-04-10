import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/tag.dart';

/// Repository for Tag and TaggedItem operations.
///
/// Manages built-in tags (Later, Bookmarks, Favorites) and
/// user-created custom tags. Handles tag-item associations.
class TagRepository {
  AppDatabase get _db => AppDatabase.instance;

  // ─── Tag CRUD ─────────────────────────────────────────────

  /// Initializes built-in tags if they don't exist.
  ///
  /// Should be called once at app startup.
  Future<void> initializeBuiltInTags() async {
    final existing = await _db.select(_db.tags).get();
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
            ),
          );
        }
      }
    });
  }

  /// Gets all tags.
  Future<List<Tag>> getAllTags() {
    return (_db.select(_db.tags)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Gets only built-in tags.
  Future<List<Tag>> getBuiltInTags() {
    return (_db.select(_db.tags)
          ..where((t) => t.isBuiltIn.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Gets only custom (user-created) tags.
  Future<List<Tag>> getCustomTags() {
    return (_db.select(_db.tags)
          ..where((t) => t.isBuiltIn.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// Gets a tag by its ID.
  Future<Tag?> getTagById(int id) {
    return (_db.select(_db.tags)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets a tag by its name.
  Future<Tag?> getTagByName(String name) {
    return (_db.select(_db.tags)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
  }

  /// Creates a new custom tag.
  Future<Tag> createTag({
    required String name,
    String? iconName,
  }) async {
    final allTags = await getAllTags();
    final sortOrder = allTags.isEmpty ? 0 : allTags.last.sortOrder + 1;

    final id = await _db.into(_db.tags).insert(
      TagsCompanion.insert(
        name: name,
        iconName: Value(iconName),
        isBuiltIn: const Value(false),
        sortOrder: Value(sortOrder),
        createdAt: DateTime.now(),
      ),
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

  /// Tags an item with a specific tag.
  Future<void> tagItem(int tagId, int itemId) async {
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
        ),
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
        await (_db.update(_db.tags)..where((t) => t.id.equals(tagId))).write(
          TagsCompanion(
            itemCount: Value((tag.itemCount - 1).clamp(0, tag.itemCount)),
          ),
        );
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

  /// Gets all item IDs with a specific tag.
  Future<List<int>> getItemIdsByTag(int tagId) async {
    final taggedItems = await (_db.select(_db.taggedItems)
          ..where((t) => t.tagId.equals(tagId)))
        .get();
    return taggedItems.map((ti) => ti.itemId).toList();
  }

  /// Gets all tag IDs for a specific item.
  Future<List<int>> getTagIdsForItem(int itemId) async {
    final taggedItems = await (_db.select(_db.taggedItems)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return taggedItems.map((ti) => ti.tagId).toList();
  }

  /// Gets the item count for a tag.
  Future<int> getTagItemCount(int tagId) async {
    final countExp = _db.taggedItems.id.count();
    final query = _db.selectOnly(_db.taggedItems)
      ..addColumns([countExp])
      ..where(_db.taggedItems.tagId.equals(tagId));
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

  /// Watches all tags for changes.
  Stream<List<Tag>> watchAllTags() {
    return (_db.select(_db.tags)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  // ─── Built-in Tag Helpers ─────────────────────────────────

  /// Gets the "Later" built-in tag.
  Future<Tag?> getLaterTag() => getTagByName(TagNames.laterName);

  /// Gets the "Bookmarks" built-in tag.
  Future<Tag?> getBookmarksTag() => getTagByName(TagNames.bookmarksName);

  /// Gets the "Favorites" built-in tag.
  Future<Tag?> getFavoritesTag() => getTagByName(TagNames.favoritesName);
}

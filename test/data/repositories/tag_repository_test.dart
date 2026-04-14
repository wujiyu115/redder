import 'package:flutter_test/flutter_test.dart';
import 'package:reeder/core/database/app_database.dart';
import 'package:reeder/data/models/tag.dart';
import 'package:reeder/data/repositories/tag_repository.dart';

void main() {
  late AppDatabase testDb;
  late TagRepository tagRepository;

  setUp(() async {
    testDb = AppDatabase.forTesting();
    tagRepository = TagRepository(db: testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('initializeBuiltInTags', () {
    test('should create built-in tags when none exist', () async {
      await tagRepository.initializeBuiltInTags();

      final allTags = await tagRepository.getAllTags();
      expect(allTags.length, equals(3));

      final laterTag = await tagRepository.getLaterTag();
      expect(laterTag, isNotNull);
      expect(laterTag!.name, equals(TagNames.laterName));
      expect(laterTag.isBuiltIn, isTrue);

      final bookmarksTag = await tagRepository.getBookmarksTag();
      expect(bookmarksTag, isNotNull);
      expect(bookmarksTag!.name, equals(TagNames.bookmarksName));
      expect(bookmarksTag.isBuiltIn, isTrue);

      final favoritesTag = await tagRepository.getFavoritesTag();
      expect(favoritesTag, isNotNull);
      expect(favoritesTag!.name, equals(TagNames.favoritesName));
      expect(favoritesTag.isBuiltIn, isTrue);
    });

    test('should be idempotent - calling multiple times does not duplicate', () async {
      await tagRepository.initializeBuiltInTags();
      await tagRepository.initializeBuiltInTags();
      await tagRepository.initializeBuiltInTags();

      final allTags = await tagRepository.getAllTags();
      expect(allTags.length, equals(3));

      final builtInTags = await tagRepository.getBuiltInTags();
      expect(builtInTags.length, equals(3));
    });

    test('should initialize built-in tags with correct sort order', () async {
      await tagRepository.initializeBuiltInTags();

      final builtInTags = await tagRepository.getBuiltInTags();
      expect(builtInTags[0].name, equals(TagNames.laterName));
      expect(builtInTags[0].sortOrder, equals(0));
      expect(builtInTags[1].name, equals(TagNames.bookmarksName));
      expect(builtInTags[1].sortOrder, equals(1));
      expect(builtInTags[2].name, equals(TagNames.favoritesName));
      expect(builtInTags[2].sortOrder, equals(2));
    });

    test('should initialize built-in tags for specific account', () async {
      const accountId = 1;
      await tagRepository.initializeBuiltInTags(accountId: accountId);

      final accountTags = await tagRepository.getAllTags(accountId: accountId);
      expect(accountTags.length, equals(3));

      final laterTag = await tagRepository.getLaterTag(accountId: accountId);
      expect(laterTag, isNotNull);
      expect(laterTag!.accountId, equals(accountId));
    });
  });

  group('createTag', () {
    setUp(() async {
      await tagRepository.initializeBuiltInTags();
    });

    test('should create custom tag', () async {
      final tag = await tagRepository.createTag(name: 'Technology');

      expect(tag.name, equals('Technology'));
      expect(tag.isBuiltIn, isFalse);
      expect(tag.id, isPositive);
    });

    test('should create custom tag with icon name', () async {
      final tag = await tagRepository.createTag(
        name: 'Science',
        iconName: 'flask',
      );

      expect(tag.name, equals('Science'));
      expect(tag.iconName, equals('flask'));
      expect(tag.isBuiltIn, isFalse);
    });

    test('should create custom tag for specific account', () async {
      const accountId = 1;
      final tag = await tagRepository.createTag(
        name: 'Work',
        accountId: accountId,
      );

      expect(tag.name, equals('Work'));
      expect(tag.accountId, equals(accountId));
    });

    test('should assign correct sort order to custom tags', () async {
      final tag1 = await tagRepository.createTag(name: 'Tag1');
      final tag2 = await tagRepository.createTag(name: 'Tag2');
      final tag3 = await tagRepository.createTag(name: 'Tag3');

      expect(tag1.sortOrder, equals(3));
      expect(tag2.sortOrder, equals(4));
      expect(tag3.sortOrder, equals(5));
    });
  });

  group('deleteTag', () {
    setUp(() async {
      await tagRepository.initializeBuiltInTags();
    });

    test('should delete custom tag', () async {
      final tag = await tagRepository.createTag(name: 'ToDelete');

      final deleted = await tagRepository.deleteTag(tag.id);
      expect(deleted, isTrue);

      final retrieved = await tagRepository.getTagById(tag.id);
      expect(retrieved, isNull);
    });

    test('should not delete built-in tags', () async {
      final laterTag = await tagRepository.getLaterTag();
      expect(laterTag, isNotNull);

      final deleted = await tagRepository.deleteTag(laterTag!.id);
      expect(deleted, isFalse);

      final stillExists = await tagRepository.getTagById(laterTag.id);
      expect(stillExists, isNotNull);
    });

    test('should remove all tagged item associations when deleting tag', () async {
      final tag = await tagRepository.createTag(name: 'CustomTag');
      const itemId = 1;

      await tagRepository.tagItem(tag.id, itemId);
      expect(await tagRepository.isItemTagged(tag.id, itemId), isTrue);

      await tagRepository.deleteTag(tag.id);

      final itemIds = await tagRepository.getItemIdsByTag(tag.id);
      expect(itemIds, isEmpty);
    });

    test('should return false when deleting non-existent tag', () async {
      final deleted = await tagRepository.deleteTag(99999);
      expect(deleted, isFalse);
    });
  });

  group('tagItem / untagItem / toggleTag', () {
    late Tag customTag;
    const itemId = 1;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      customTag = await tagRepository.createTag(name: 'TestTag');
    });

    test('should tag an item', () async {
      await tagRepository.tagItem(customTag.id, itemId);

      expect(await tagRepository.isItemTagged(customTag.id, itemId), isTrue);

      final itemIds = await tagRepository.getItemIdsByTag(customTag.id);
      expect(itemIds, contains(itemId));
    });

    test('should be idempotent - tagging same item multiple times', () async {
      await tagRepository.tagItem(customTag.id, itemId);
      await tagRepository.tagItem(customTag.id, itemId);
      await tagRepository.tagItem(customTag.id, itemId);

      final itemIds = await tagRepository.getItemIdsByTag(customTag.id);
      expect(itemIds, hasLength(1));
    });

    test('should untag an item', () async {
      await tagRepository.tagItem(customTag.id, itemId);
      expect(await tagRepository.isItemTagged(customTag.id, itemId), isTrue);

      await tagRepository.untagItem(customTag.id, itemId);

      expect(await tagRepository.isItemTagged(customTag.id, itemId), isFalse);

      final itemIds = await tagRepository.getItemIdsByTag(customTag.id);
      expect(itemIds, isEmpty);
    });

    test('should be idempotent - untagging same item multiple times', () async {
      await tagRepository.tagItem(customTag.id, itemId);
      await tagRepository.untagItem(customTag.id, itemId);
      await tagRepository.untagItem(customTag.id, itemId);

      expect(await tagRepository.isItemTagged(customTag.id, itemId), isFalse);
    });

    test('toggleTag should add tag when item is not tagged', () async {
      final result = await tagRepository.toggleTag(customTag.id, itemId);

      expect(result, isTrue);
      expect(await tagRepository.isItemTagged(customTag.id, itemId), isTrue);
    });

    test('toggleTag should remove tag when item is tagged', () async {
      await tagRepository.tagItem(customTag.id, itemId);

      final result = await tagRepository.toggleTag(customTag.id, itemId);

      expect(result, isFalse);
      expect(await tagRepository.isItemTagged(customTag.id, itemId), isFalse);
    });

    test('should tag item with built-in tag', () async {
      final laterTag = await tagRepository.getLaterTag();
      expect(laterTag, isNotNull);

      await tagRepository.tagItem(laterTag!.id, itemId);

      expect(await tagRepository.isItemTagged(laterTag.id, itemId), isTrue);
    });

    test('should update tag item count when tagging', () async {
      expect(customTag.itemCount, equals(0));

      await tagRepository.tagItem(customTag.id, itemId);

      final updatedTag = await tagRepository.getTagById(customTag.id);
      expect(updatedTag!.itemCount, equals(1));
    });

    test('should update tag item count when untagging', () async {
      await tagRepository.tagItem(customTag.id, itemId);

      await tagRepository.untagItem(customTag.id, itemId);

      final updatedTag = await tagRepository.getTagById(customTag.id);
      expect(updatedTag!.itemCount, equals(0));
    });
  });

  group('getItemIdsByTag / getTagIdsForItem', () {
    late Tag tag1;
    late Tag tag2;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      tag1 = await tagRepository.createTag(name: 'Tag1');
      tag2 = await tagRepository.createTag(name: 'Tag2');
    });

    test('should get item IDs by tag', () async {
      await tagRepository.tagItem(tag1.id, 1);
      await tagRepository.tagItem(tag1.id, 2);
      await tagRepository.tagItem(tag1.id, 3);

      final itemIds = await tagRepository.getItemIdsByTag(tag1.id);
      expect(itemIds, unorderedEquals([1, 2, 3]));
    });

    test('should return empty list when tag has no items', () async {
      final itemIds = await tagRepository.getItemIdsByTag(tag2.id);
      expect(itemIds, isEmpty);
    });

    test('should get tag IDs for item', () async {
      await tagRepository.tagItem(tag1.id, 1);
      await tagRepository.tagItem(tag2.id, 1);
      await tagRepository.tagItem(tag1.id, 2);

      final tagIds = await tagRepository.getTagIdsForItem(1);
      expect(tagIds, unorderedEquals([tag1.id, tag2.id]));
    });

    test('should return empty list when item has no tags', () async {
      final tagIds = await tagRepository.getTagIdsForItem(999);
      expect(tagIds, isEmpty);
    });

    test('should filter by account ID', () async {
      const accountId = 1;
      final accountTag = await tagRepository.createTag(
        name: 'AccountTag',
        accountId: accountId,
      );

      await tagRepository.tagItem(accountTag.id, 1, accountId: accountId);

      final itemIds = await tagRepository.getItemIdsByTag(
        accountTag.id,
        accountId: accountId,
      );
      expect(itemIds, contains(1));

      final itemIdsNoFilter = await tagRepository.getItemIdsByTag(accountTag.id);
      expect(itemIdsNoFilter, contains(1));
    });
  });

  group('getLaterTag / getBookmarksTag / getFavoritesTag', () {
    setUp(() async {
      await tagRepository.initializeBuiltInTags();
    });

    test('should get Later tag', () async {
      final laterTag = await tagRepository.getLaterTag();

      expect(laterTag, isNotNull);
      expect(laterTag!.name, equals(TagNames.laterName));
      expect(laterTag.isBuiltIn, isTrue);
      expect(laterTag.iconName, equals('clock'));
    });

    test('should get Bookmarks tag', () async {
      final bookmarksTag = await tagRepository.getBookmarksTag();

      expect(bookmarksTag, isNotNull);
      expect(bookmarksTag!.name, equals(TagNames.bookmarksName));
      expect(bookmarksTag.isBuiltIn, isTrue);
      expect(bookmarksTag.iconName, equals('bookmark'));
    });

    test('should get Favorites tag', () async {
      final favoritesTag = await tagRepository.getFavoritesTag();

      expect(favoritesTag, isNotNull);
      expect(favoritesTag!.name, equals(TagNames.favoritesName));
      expect(favoritesTag.isBuiltIn, isTrue);
      expect(favoritesTag.iconName, equals('heart'));
    });

    test('should get built-in tags for specific account', () async {
      const accountId = 1;
      await tagRepository.initializeBuiltInTags(accountId: accountId);

      final laterTag = await tagRepository.getLaterTag(accountId: accountId);
      expect(laterTag, isNotNull);
      expect(laterTag!.accountId, equals(accountId));

      final bookmarksTag = await tagRepository.getBookmarksTag(accountId: accountId);
      expect(bookmarksTag, isNotNull);
      expect(bookmarksTag!.accountId, equals(accountId));

      final favoritesTag = await tagRepository.getFavoritesTag(accountId: accountId);
      expect(favoritesTag, isNotNull);
      expect(favoritesTag!.accountId, equals(accountId));
    });

    test('should return null when built-in tags not initialized', () async {
      final noInitDb = AppDatabase.forTesting();
      final noInitRepo = TagRepository(db: noInitDb);

      final laterTag = await noInitRepo.getLaterTag();
      expect(laterTag, isNull);

      await noInitDb.close();
    });
  });

  group('getTagItemCount', () {
    late Tag customTag;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      customTag = await tagRepository.createTag(name: 'TestTag');
    });

    test('should return correct item count', () async {
      expect(await tagRepository.getTagItemCount(customTag.id), equals(0));

      await tagRepository.tagItem(customTag.id, 1);
      expect(await tagRepository.getTagItemCount(customTag.id), equals(1));

      await tagRepository.tagItem(customTag.id, 2);
      expect(await tagRepository.getTagItemCount(customTag.id), equals(2));

      await tagRepository.tagItem(customTag.id, 3);
      expect(await tagRepository.getTagItemCount(customTag.id), equals(3));
    });

    test('should count items correctly after untagging', () async {
      await tagRepository.tagItem(customTag.id, 1);
      await tagRepository.tagItem(customTag.id, 2);
      await tagRepository.tagItem(customTag.id, 3);

      expect(await tagRepository.getTagItemCount(customTag.id), equals(3));

      await tagRepository.untagItem(customTag.id, 2);

      expect(await tagRepository.getTagItemCount(customTag.id), equals(2));
    });

    test('should filter by account ID', () async {
      const accountId = 1;
      final accountTag = await tagRepository.createTag(
        name: 'AccountTag',
        accountId: accountId,
      );

      await tagRepository.tagItem(accountTag.id, 1, accountId: accountId);
      await tagRepository.tagItem(accountTag.id, 2, accountId: accountId);

      final count = await tagRepository.getTagItemCount(
        accountTag.id,
        accountId: accountId,
      );
      expect(count, equals(2));
    });
  });

  group('removeAllTagsForItem', () {
    late Tag tag1;
    late Tag tag2;
    late Tag tag3;
    const itemId = 1;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      tag1 = await tagRepository.createTag(name: 'Tag1');
      tag2 = await tagRepository.createTag(name: 'Tag2');
      tag3 = await tagRepository.createTag(name: 'Tag3');

      await tagRepository.tagItem(tag1.id, itemId);
      await tagRepository.tagItem(tag2.id, itemId);
      await tagRepository.tagItem(tag3.id, itemId);
    });

    test('should remove all tags from item', () async {
      expect(await tagRepository.getTagIdsForItem(itemId), hasLength(3));

      await tagRepository.removeAllTagsForItem(itemId);

      expect(await tagRepository.getTagIdsForItem(itemId), isEmpty);
    });

    test('should update tag item counts when removing all tags', () async {
      expect(await tagRepository.getTagItemCount(tag1.id), equals(1));
      expect(await tagRepository.getTagItemCount(tag2.id), equals(1));
      expect(await tagRepository.getTagItemCount(tag3.id), equals(1));

      await tagRepository.removeAllTagsForItem(itemId);

      expect(await tagRepository.getTagItemCount(tag1.id), equals(0));
      expect(await tagRepository.getTagItemCount(tag2.id), equals(0));
      expect(await tagRepository.getTagItemCount(tag3.id), equals(0));
    });

    test('should be idempotent - removing all tags multiple times', () async {
      await tagRepository.removeAllTagsForItem(itemId);
      await tagRepository.removeAllTagsForItem(itemId);
      await tagRepository.removeAllTagsForItem(itemId);

      expect(await tagRepository.getTagIdsForItem(itemId), isEmpty);
    });
  });

  group('getAllTags / getBuiltInTags / getCustomTags', () {
    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      await tagRepository.createTag(name: 'Custom1');
      await tagRepository.createTag(name: 'Custom2');
    });

    test('should get all tags', () async {
      final allTags = await tagRepository.getAllTags();
      expect(allTags.length, equals(5));
    });

    test('should get only built-in tags', () async {
      final builtInTags = await tagRepository.getBuiltInTags();
      expect(builtInTags.length, equals(3));

      for (final tag in builtInTags) {
        expect(tag.isBuiltIn, isTrue);
      }
    });

    test('should get only custom tags', () async {
      final customTags = await tagRepository.getCustomTags();
      expect(customTags.length, equals(2));

      for (final tag in customTags) {
        expect(tag.isBuiltIn, isFalse);
      }
    });

    test('should filter tags by account ID', () async {
      const accountId = 1;
      await tagRepository.initializeBuiltInTags(accountId: accountId);
      await tagRepository.createTag(name: 'AccountCustom1', accountId: accountId);
      await tagRepository.createTag(name: 'AccountCustom2', accountId: accountId);

      final accountTags = await tagRepository.getAllTags(accountId: accountId);
      expect(accountTags.length, equals(5));

      final accountBuiltIn = await tagRepository.getBuiltInTags(accountId: accountId);
      expect(accountBuiltIn.length, equals(3));

      final accountCustom = await tagRepository.getCustomTags(accountId: accountId);
      expect(accountCustom.length, equals(2));
    });
  });

  group('getTagById / getTagByName', () {
    late Tag customTag;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      customTag = await tagRepository.createTag(name: 'TestTag');
    });

    test('should get tag by ID', () async {
      final retrieved = await tagRepository.getTagById(customTag.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals(customTag.id));
      expect(retrieved.name, equals(customTag.name));
    });

    test('should return null when getting non-existent tag by ID', () async {
      final retrieved = await tagRepository.getTagById(99999);
      expect(retrieved, isNull);
    });

    test('should get tag by name', () async {
      final retrieved = await tagRepository.getTagByName('TestTag');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('TestTag'));
    });

    test('should return null when getting non-existent tag by name', () async {
      final retrieved = await tagRepository.getTagByName('NonExistent');
      expect(retrieved, isNull);
    });

    test('should filter by account ID when getting by ID', () async {
      const accountId = 1;
      final accountTag = await tagRepository.createTag(
        name: 'AccountTag',
        accountId: accountId,
      );

      final retrieved = await tagRepository.getTagById(
        accountTag.id,
        accountId: accountId,
      );
      expect(retrieved, isNotNull);

      final noFilter = await tagRepository.getTagById(accountTag.id);
      expect(noFilter, isNotNull);
    });

    test('should filter by account ID when getting by name', () async {
      const accountId = 1;
      await tagRepository.createTag(name: 'SameName');
      await tagRepository.createTag(name: 'SameName', accountId: accountId);

      final accountTag = await tagRepository.getTagByName(
        'SameName',
        accountId: accountId,
      );
      expect(accountTag, isNotNull);
      expect(accountTag!.accountId, equals(accountId));
    });
  });

  group('updateTag', () {
    late Tag customTag;

    setUp(() async {
      await tagRepository.initializeBuiltInTags();
      customTag = await tagRepository.createTag(name: 'OriginalName');
    });

    test('should update tag properties', () async {
      final updatedTag = Tag(
        id: customTag.id,
        name: 'UpdatedName',
        iconName: 'updated_icon',
        accountId: customTag.accountId,
        isBuiltIn: customTag.isBuiltIn,
        isShared: true,
        sharedFeedUrl: 'https://example.com/feed',
        itemCount: customTag.itemCount,
        sortOrder: customTag.sortOrder,
        createdAt: customTag.createdAt,
      );

      await tagRepository.updateTag(updatedTag);

      final retrieved = await tagRepository.getTagById(customTag.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('UpdatedName'));
      expect(retrieved.iconName, equals('updated_icon'));
      expect(retrieved.isShared, isTrue);
      expect(retrieved.sharedFeedUrl, equals('https://example.com/feed'));
    });

    test('should update tag sort order', () async {
      final updatedTag = Tag(
        id: customTag.id,
        name: customTag.name,
        iconName: customTag.iconName,
        accountId: customTag.accountId,
        isBuiltIn: customTag.isBuiltIn,
        isShared: customTag.isShared,
        sharedFeedUrl: customTag.sharedFeedUrl,
        itemCount: customTag.itemCount,
        sortOrder: 999,
        createdAt: customTag.createdAt,
      );

      await tagRepository.updateTag(updatedTag);

      final retrieved = await tagRepository.getTagById(customTag.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.sortOrder, equals(999));
    });
  });
}

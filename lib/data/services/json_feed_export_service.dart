import 'dart:convert';

import '../../core/database/app_database.dart';
import '../repositories/tag_repository.dart';
import '../repositories/article_repository.dart';

/// Service for exporting tagged articles as JSON Feed format.
///
/// JSON Feed is a syndication format similar to RSS/Atom but using JSON.
/// Specification: https://www.jsonfeed.org/version/1.1/
///
/// This allows users to share their curated tag collections as
/// subscribable feeds.
class JsonFeedExportService {
  final TagRepository _tagRepository;
  final ArticleRepository _articleRepository;

  JsonFeedExportService({
    required TagRepository tagRepository,
    required ArticleRepository articleRepository,
  })  : _tagRepository = tagRepository,
        _articleRepository = articleRepository;

  /// Exports a tag's articles as a JSON Feed string.
  ///
  /// [tagId] - The tag to export.
  /// [feedTitle] - Optional custom title for the feed.
  /// [feedDescription] - Optional description.
  /// [homePageUrl] - Optional home page URL.
  /// [limit] - Maximum number of items to include (default: 100).
  ///
  /// Returns a JSON string conforming to JSON Feed 1.1 specification.
  Future<String> exportTagAsJsonFeed({
    required int tagId,
    String? feedTitle,
    String? feedDescription,
    String? homePageUrl,
    int limit = 100,
  }) async {
    // Get the tag
    final tag = await _tagRepository.getTagById(tagId);
    if (tag == null) {
      throw ArgumentError('Tag with id $tagId not found');
    }

    // Get all item IDs for this tag
    final itemIds = await _tagRepository.getItemIdsByTag(tagId);

    // Fetch the actual articles
    final articles = <FeedItem>[];
    for (final itemId in itemIds) {
      final article = await _articleRepository.getArticleById(itemId);
      if (article != null) {
        articles.add(article);
      }
      if (articles.length >= limit) break;
    }

    // Sort by published date (newest first)
    articles.sort((a, b) {
      return b.publishedAt.compareTo(a.publishedAt);
    });

    // Build JSON Feed
    final feed = {
      'version': 'https://jsonfeed.org/version/1.1',
      'title': feedTitle ?? '${tag.name} - Reeder',
      if (feedDescription != null) 'description': feedDescription,
      if (homePageUrl != null) 'home_page_url': homePageUrl,
      'items': articles.map((article) => _articleToJsonFeedItem(article)).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(feed);
  }

  /// Exports all tags as a map of tag name → JSON Feed string.
  Future<Map<String, String>> exportAllTagsAsJsonFeeds({
    int limitPerTag = 50,
  }) async {
    final tags = await _tagRepository.getAllTags();
    final result = <String, String>{};

    for (final tag in tags) {
      final itemCount = await _tagRepository.getTagItemCount(tag.id);
      if (itemCount > 0) {
        result[tag.name] = await exportTagAsJsonFeed(
          tagId: tag.id,
          limit: limitPerTag,
        );
      }
    }

    return result;
  }

  /// Converts a [FeedItem] to a JSON Feed item map.
  Map<String, dynamic> _articleToJsonFeedItem(FeedItem article) {
    final item = <String, dynamic>{
      'id': article.url,
      'title': article.title,
    };

    item['url'] = article.url;

    if (article.content != null && article.content!.isNotEmpty) {
      item['content_html'] = article.content;
    }

    if (article.summary != null && article.summary!.isNotEmpty) {
      item['summary'] = article.summary;
    }

    if (article.imageUrl != null) {
      item['image'] = article.imageUrl;
    }

    if (article.author != null) {
      item['authors'] = [
        {'name': article.author},
      ];
    }

    item['date_published'] = article.publishedAt.toUtc().toIso8601String();

    // Add attachments for audio/video content
    final attachments = <Map<String, dynamic>>[];

    if (article.audioUrl != null) {
      attachments.add({
        'url': article.audioUrl,
        'mime_type': 'audio/mpeg',
        if (article.audioDuration != null)
          'duration_in_seconds': article.audioDuration,
      });
    }

    if (article.videoUrl != null) {
      attachments.add({
        'url': article.videoUrl,
        'mime_type': 'video/mp4',
      });
    }

    if (attachments.isNotEmpty) {
      item['attachments'] = attachments;
    }

    return item;
  }
}

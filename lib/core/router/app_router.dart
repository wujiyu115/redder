import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/reeder_page_transition.dart';
import '../../features/source_list/source_list_page.dart';
import '../../features/article_list/article_list_page.dart';
import '../../features/article_detail/article_detail_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/settings/theme_settings_page.dart';
import '../../features/settings/reading_settings_page.dart';
import '../../features/settings/data_settings_page.dart';
import '../../features/settings/about_page.dart';
import '../../features/settings/timeline_settings_page.dart';
import '../../features/settings/accounts_page.dart';
import '../../features/settings/add_account_page.dart';
import '../../features/settings/service_login_page.dart';
import '../../features/settings/edit_account_page.dart';
import '../../features/search/search_page.dart';
import '../../features/filter/filter_editor_page.dart';
import '../../features/image_viewer/image_viewer_page.dart';
import '../../features/podcast_player/full_player_page.dart';
import '../../features/video_player/video_player_page.dart';
import '../../features/browser/in_app_browser_page.dart';

/// Provider for the app router configuration.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'sourceList',
        pageBuilder: (context, state) => ReederPage(
          key: state.pageKey,
          child: const SourceListPage(),
        ),
        routes: [
          GoRoute(
            path: 'timeline/:id',
            name: 'articleList',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: ArticleListPage(
                timelineId: state.pathParameters['id'] ?? 'all',
              ),
            ),
            routes: [
              GoRoute(
                path: 'article/:articleId',
                name: 'articleDetail',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: ArticleDetailPage(
                    articleId: int.tryParse(state.pathParameters['articleId'] ?? '') ?? 0,
                    timelineId: state.pathParameters['id'] ?? 'all',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
            routes: [
              GoRoute(
                path: 'theme',
                name: 'themeSettings',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const ThemeSettingsPage(),
                ),
              ),
              GoRoute(
                path: 'reading',
                name: 'readingSettings',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const ReadingSettingsPage(),
                ),
              ),
              GoRoute(
                path: 'data',
                name: 'dataSettings',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const DataSettingsPage(),
                ),
              ),
              GoRoute(
                path: 'about',
                name: 'about',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const AboutPage(),
                ),
              ),
              GoRoute(
                path: 'timeline',
                name: 'timelineSettings',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const TimelineSettingsPage(),
                ),
              ),
              GoRoute(
                path: 'accounts',
                name: 'accounts',
                pageBuilder: (context, state) => ReederPage(
                  key: state.pageKey,
                  child: const AccountsPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'addAccount',
                    pageBuilder: (context, state) => ReederPage(
                      key: state.pageKey,
                      child: const AddAccountPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'login/:serviceType',
                    name: 'serviceLogin',
                    pageBuilder: (context, state) => ReederPage(
                      key: state.pageKey,
                      child: ServiceLoginPage(
                        serviceType: state.pathParameters['serviceType'] ?? 'feedbin',
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'edit/:accountId',
                    name: 'editAccount',
                    pageBuilder: (context, state) {
                      final accountId = int.tryParse(
                            state.pathParameters['accountId'] ?? '',
                          ) ??
                          0;
                      return ReederPage(
                        key: state.pageKey,
                        child: EditAccountPage(accountId: accountId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'search',
            name: 'search',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: const SearchPage(),
            ),
          ),
          GoRoute(
            path: 'filter/new',
            name: 'filterNew',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: const FilterEditorPage(),
            ),
          ),
          GoRoute(
            path: 'filter/:filterId',
            name: 'filterEdit',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: FilterEditorPage(
                filterId: int.tryParse(state.pathParameters['filterId'] ?? ''),
              ),
            ),
          ),
          GoRoute(
            path: 'image-viewer',
            name: 'imageViewer',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return ReederPage(
                key: state.pageKey,
                child: ImageViewerPage(
                  imageUrls: (extra['imageUrls'] as List<String>?) ?? [],
                  initialIndex: (extra['initialIndex'] as int?) ?? 0,
                  heroTag: extra['heroTag'] as String?,
                ),
              );
            },
          ),
          GoRoute(
            path: 'podcast-player',
            name: 'podcastPlayer',
            pageBuilder: (context, state) => ReederPage(
              key: state.pageKey,
              child: const FullPlayerPage(),
            ),
          ),
          GoRoute(
            path: 'video-player',
            name: 'videoPlayer',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return ReederPage(
                key: state.pageKey,
                child: VideoPlayerPage(
                  videoUrl: extra['videoUrl'] as String?,
                  embedUrl: extra['embedUrl'] as String?,
                  title: extra['title'] as String?,
                ),
              );
            },
          ),
          GoRoute(
            path: 'browser',
            name: 'browser',
            pageBuilder: (context, state) {
              final url = state.extra as String? ?? '';
              return ReederPage(
                key: state.pageKey,
                child: InAppBrowserPage(url: url),
              );
            },
          ),
        ],
      ),
    ],
  );
});

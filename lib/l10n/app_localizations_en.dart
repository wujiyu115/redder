// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Reeder';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get compactMode => 'Compact Mode';

  @override
  String get compactModeDesc => 'Show articles without thumbnails';

  @override
  String get showThumbnails => 'Show Thumbnails';

  @override
  String get showFeedIcons => 'Show Feed Icons';

  @override
  String get reading => 'Reading';

  @override
  String get fontSizeAndLineHeight => 'Font Size & Line Height';

  @override
  String get fontSizeAndLineHeightDesc => 'Customize reading experience';

  @override
  String get bionicReading => 'Bionic Reading';

  @override
  String get bionicReadingDesc =>
      'Bold the beginning of words for faster reading';

  @override
  String get markAsReadOnScroll => 'Mark as Read on Scroll';

  @override
  String get markAsReadOnScrollDesc =>
      'Automatically mark articles as read when scrolled past';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get timeline => 'Timeline';

  @override
  String get timelineDesc => 'Sort order, grouping, content expiry';

  @override
  String get data => 'Data';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get dataAndStorageDesc => 'Cache, refresh, import/export';

  @override
  String get about => 'About';

  @override
  String get aboutReeder => 'About Reeder';

  @override
  String get resetAllSettings => 'Reset All Settings';

  @override
  String get reset => 'Reset';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDesc => 'Clean white background';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDesc => 'Easy on the eyes';

  @override
  String get themeOled => 'OLED Black';

  @override
  String get themeOledDesc => 'True black for OLED displays';

  @override
  String get themeDarkLight => 'Dark Light';

  @override
  String get themeDarkLightDesc => 'Dark list, light reading view';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Follow system appearance';

  @override
  String get automatic => 'Automatic';

  @override
  String get fontSize => 'Font Size';

  @override
  String get lineHeight => 'Line Height';

  @override
  String get preview => 'Preview';

  @override
  String get previewText =>
      'The quick brown fox jumps over the lazy dog. This is a preview of how your articles will look with the current font size and line height settings. Adjust the sliders above to find your preferred reading experience.';

  @override
  String get refresh => 'Refresh';

  @override
  String get autoRefresh => 'Auto-Refresh';

  @override
  String get autoRefreshInterval => 'Auto-Refresh Interval';

  @override
  String get content => 'Content';

  @override
  String get contentExpiry => 'Content Expiry';

  @override
  String get contentExpiryDesc => 'Automatically hide old articles';

  @override
  String get cacheImages => 'Cache Images';

  @override
  String get cacheImagesDesc => 'Save images for offline reading';

  @override
  String get importExport => 'Import / Export';

  @override
  String get importOpml => 'Import OPML';

  @override
  String get importOpmlDesc => 'Import subscriptions from an OPML file';

  @override
  String get exportOpml => 'Export OPML';

  @override
  String get exportOpmlDesc => 'Export all subscriptions as OPML 2.0';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc => 'Remove all feeds, articles, and settings';

  @override
  String get clear => 'Clear';

  @override
  String get clearAllDataConfirmTitle => 'Clear All Data';

  @override
  String get clearAllDataConfirmMessage =>
      'This will permanently delete all feeds, articles, tags, and settings. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clearAll => 'Clear All';

  @override
  String get manual => 'Manual';

  @override
  String refreshIntervalMin(int minutes) {
    return '${minutes}min';
  }

  @override
  String refreshIntervalHour(int hours) {
    return '${hours}h';
  }

  @override
  String get never => 'Never';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String monthCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String yearCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get appDescription => 'A beautiful RSS reader built with Flutter';

  @override
  String get links => 'Links';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get sourceCode => 'Source Code';

  @override
  String get viewOnGithub => 'View on GitHub';

  @override
  String get acknowledgments => 'Acknowledgments';

  @override
  String get flutter => 'Flutter';

  @override
  String get flutterDesc => 'UI framework by Google';

  @override
  String get riverpod => 'Riverpod';

  @override
  String get riverpodDesc => 'State management';

  @override
  String get isar => 'Isar';

  @override
  String get isarDesc => 'Local database';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get madeWithFlutter => 'Made with ❤ using Flutter';

  @override
  String get home => 'Home';

  @override
  String get all => 'All';

  @override
  String get articles => 'Articles';

  @override
  String get podcasts => 'Podcasts';

  @override
  String get videos => 'Videos';

  @override
  String get feeds => 'Feeds';

  @override
  String get tags => 'Tags';

  @override
  String get newFolder => 'New Folder';

  @override
  String get newTag => 'New Tag';

  @override
  String get newFilter => 'New Filter';

  @override
  String get filters => 'Filters';

  @override
  String get addFeed => 'Add Feed';

  @override
  String get enterFeedUrl => 'Enter feed or website URL';

  @override
  String get searching => 'Searching...';

  @override
  String foundFeeds(int count) {
    return 'Found $count feed(s):';
  }

  @override
  String get pleaseEnterUrl => 'Please enter a URL';

  @override
  String get noFeedsFound => 'No feeds found at this URL';

  @override
  String errorDiscoveringFeeds(String error) {
    return 'Error discovering feeds: $error';
  }

  @override
  String get discoverFeeds => 'Discover Feeds';

  @override
  String feedItemsInfo(int count, String type) {
    return '$count items · $type';
  }

  @override
  String get later => 'Later';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get favorite => 'Favorite';

  @override
  String get share => 'Share';

  @override
  String get browser => 'Browser';

  @override
  String get search => 'Search';

  @override
  String get searchArticles => 'Search articles...';

  @override
  String get searchYourArticles => 'Search your articles';

  @override
  String get searchByTitleContentAuthor =>
      'Search by title, content, or author.';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentKeywords => 'Try different keywords.';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get unknownEpisode => 'Unknown Episode';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get noEpisodePlaying => 'No episode playing';

  @override
  String get chapters => 'CHAPTERS';

  @override
  String get video => 'Video';

  @override
  String get failedToPlayVideo => 'Failed to play video';

  @override
  String get unableToPlayVideo => 'Unable to play video';

  @override
  String get loadingVideo => 'Loading video...';

  @override
  String get editFilter => 'Edit Filter';

  @override
  String get newFilterTitle => 'New Filter';

  @override
  String get save => 'Save';

  @override
  String get name => 'Name';

  @override
  String get filterName => 'Filter name';

  @override
  String get includeKeywords => 'Include Keywords';

  @override
  String get includeKeywordsDesc =>
      'Items must contain at least one of these keywords.';

  @override
  String get excludeKeywords => 'Exclude Keywords';

  @override
  String get excludeKeywordsDesc =>
      'Items containing any of these keywords will be filtered out.';

  @override
  String get contentTypes => 'Content Types';

  @override
  String get contentTypesDesc => 'Leave empty to include all content types.';

  @override
  String get feedTypes => 'Feed Types';

  @override
  String get feedTypesDesc => 'Leave empty to include all feed types.';

  @override
  String get options => 'Options';

  @override
  String get matchWholeWords => 'Match Whole Words';

  @override
  String get matchWholeWordsDesc =>
      'Only match complete words, not partial matches.';

  @override
  String get addKeyword => 'Add keyword...';

  @override
  String get article => 'Article';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Image';

  @override
  String get blog => 'Blog';

  @override
  String get podcast => 'Podcast';

  @override
  String get mixed => 'Mixed';

  @override
  String get deleteFilter => 'Delete Filter';

  @override
  String deleteFilterConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get pleaseEnterFilterName => 'Please enter a filter name.';

  @override
  String failedToSaveFilter(String error) {
    return 'Failed to save filter: $error';
  }

  @override
  String get ok => 'OK';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkYourConnection => 'Check your connection and try again';

  @override
  String get failedToLoadFeed => 'Failed to load feed';

  @override
  String get failedToParseContent => 'Failed to parse content';

  @override
  String get feedFormatNotSupported => 'The feed format may not be supported';

  @override
  String get retry => 'Retry';

  @override
  String get noArticlesYet => 'No articles yet';

  @override
  String get pullDownToRefresh => 'Pull down to refresh or add a new feed';

  @override
  String get noFeedsYet => 'No feeds yet';

  @override
  String get addFeedToGetStarted => 'Add your first RSS feed to get started';

  @override
  String get noTaggedItems => 'No tagged items';

  @override
  String get tagArticlesToFindHere => 'Tag articles to find them here';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get defaultViewer => 'DEFAULT VIEWER';

  @override
  String get articleViewer => 'Article';

  @override
  String get readerView => 'Reader View';

  @override
  String get autoReaderView => 'Auto Reader View';

  @override
  String get moveTo => 'Move to Folder';

  @override
  String get noFolder => 'No Folder';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String unsubscribeConfirm(String name) {
    return 'Are you sure you want to unsubscribe from \"$name\"? All articles from this feed will be deleted.';
  }

  @override
  String get rename => 'Rename';

  @override
  String get create => 'Create';

  @override
  String get folderName => 'Folder name';

  @override
  String get tagName => 'Tag name';

  @override
  String get renameFolder => 'Rename Folder';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String deleteFolderConfirm(String name) {
    return 'Delete \"$name\"? Feeds in this folder will be moved to the root level.';
  }

  @override
  String get renameTag => 'Rename Tag';

  @override
  String get deleteTag => 'Delete Tag';

  @override
  String deleteTagConfirm(String name) {
    return 'Delete \"$name\"? All tag associations will be removed.';
  }

  @override
  String get refreshFeed => 'Refresh';

  @override
  String get accounts => 'Accounts';

  @override
  String get syncAccounts => 'Sync Accounts';

  @override
  String get syncAccountsDesc => 'Manage sync service accounts';

  @override
  String get addAccount => 'Add Account';

  @override
  String get noSyncAccounts => 'No sync accounts configured';

  @override
  String get timelineSettingsTitle => 'Timeline';

  @override
  String get sortOrderSection => 'SORT ORDER';

  @override
  String get behaviorSection => 'BEHAVIOR';

  @override
  String get contentExpirySection => 'CONTENT EXPIRY';

  @override
  String get groupByFeed => 'Group by Feed';

  @override
  String get groupByFeedDesc => 'Group articles by their source feed';

  @override
  String get contentExpiryHint =>
      'Articles older than the selected period will be hidden from timelines. They can still be found via search.';

  @override
  String get oneWeek => '1 Week';

  @override
  String get twoWeeks => '2 Weeks';

  @override
  String get oneMonth => '1 Month';

  @override
  String get threeMonths => '3 Months';

  @override
  String get sixMonths => '6 Months';

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirm(String serviceName, String detail) {
    return 'Are you sure you want to delete the $serviceName account ($detail)? This action cannot be undone.';
  }

  @override
  String get active => 'Active';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get neverSynced => 'Never synced';

  @override
  String get thirdPartyServices => 'Third-Party Services';

  @override
  String get selfHostedServices => 'Self-Hosted Services';

  @override
  String get feedbinDesc => 'Email & password';

  @override
  String get feedlyDesc => 'Sign in with your account';

  @override
  String get inoreaderDesc => 'Sign in with your account';

  @override
  String get freshRssDesc => 'Server URL, username & password';

  @override
  String get readerDesc => 'Server URL, username & password';

  @override
  String signInWith(String service) {
    return 'Sign in with $service';
  }

  @override
  String signInDesc(String service) {
    return 'Sign in to your $service account to sync your subscriptions and reading progress.';
  }

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint => 'https://reader.example.com';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidServerUrl =>
      'Please enter a valid URL starting with http:// or https://';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String oauthNotConfigured(String service) {
    return 'OAuth sign-in for $service is not yet configured. Please use a service that supports username & password login.';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get accountUpdated => 'Account updated successfully';

  @override
  String get verifyingCredentials => 'Verifying credentials…';

  @override
  String get loginSuccess => 'Login successful! Refreshing subscriptions…';

  @override
  String get authenticationFailed =>
      'Authentication failed. Please check your credentials.';

  @override
  String get star => 'Star';

  @override
  String get unstar => 'Unstar';

  @override
  String get markRead => 'Mark Read';

  @override
  String get markUnread => 'Mark Unread';

  @override
  String get markAllAsRead => 'Mark All as Read';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get logout => 'Log Out';

  @override
  String logoutConfirm(String serviceName) {
    return 'Are you sure you want to log out of $serviceName?';
  }

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncIdle => 'Idle';

  @override
  String get syncError => 'Sync Error';
}

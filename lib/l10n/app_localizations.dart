import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Reeder'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @compactMode.
  ///
  /// In en, this message translates to:
  /// **'Compact Mode'**
  String get compactMode;

  /// No description provided for @compactModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Show articles without thumbnails'**
  String get compactModeDesc;

  /// No description provided for @showThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show Thumbnails'**
  String get showThumbnails;

  /// No description provided for @showFeedIcons.
  ///
  /// In en, this message translates to:
  /// **'Show Feed Icons'**
  String get showFeedIcons;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @fontSizeAndLineHeight.
  ///
  /// In en, this message translates to:
  /// **'Font Size & Line Height'**
  String get fontSizeAndLineHeight;

  /// No description provided for @fontSizeAndLineHeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize reading experience'**
  String get fontSizeAndLineHeightDesc;

  /// No description provided for @bionicReading.
  ///
  /// In en, this message translates to:
  /// **'Bionic Reading'**
  String get bionicReading;

  /// No description provided for @bionicReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Bold the beginning of words for faster reading'**
  String get bionicReadingDesc;

  /// No description provided for @fullscreenReading.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen Reading'**
  String get fullscreenReading;

  /// No description provided for @fullscreenReadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Open articles in a distraction-free fullscreen view by default'**
  String get fullscreenReadingDesc;

  /// No description provided for @markAsReadOnScroll.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read on Scroll'**
  String get markAsReadOnScroll;

  /// No description provided for @markAsReadOnScrollDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically mark articles as read when scrolled past'**
  String get markAsReadOnScrollDesc;

  /// No description provided for @hideReadArticles.
  ///
  /// In en, this message translates to:
  /// **'Hide Read Articles'**
  String get hideReadArticles;

  /// No description provided for @hideReadArticlesDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove articles from the timeline once they are read'**
  String get hideReadArticlesDesc;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @timelineDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort order, grouping, content expiry'**
  String get timelineDesc;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @dataAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataAndStorage;

  /// No description provided for @dataAndStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Cache, refresh, import/export'**
  String get dataAndStorageDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutReeder.
  ///
  /// In en, this message translates to:
  /// **'About Reeder'**
  String get aboutReeder;

  /// No description provided for @resetAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset All Settings'**
  String get resetAllSettings;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean white background'**
  String get themeLightDesc;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes'**
  String get themeDarkDesc;

  /// No description provided for @themeOled.
  ///
  /// In en, this message translates to:
  /// **'OLED Black'**
  String get themeOled;

  /// No description provided for @themeOledDesc.
  ///
  /// In en, this message translates to:
  /// **'True black for OLED displays'**
  String get themeOledDesc;

  /// No description provided for @themeDarkLight.
  ///
  /// In en, this message translates to:
  /// **'Dark Light'**
  String get themeDarkLight;

  /// No description provided for @themeDarkLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark list, light reading view'**
  String get themeDarkLightDesc;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow system appearance'**
  String get themeSystemDesc;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @lineHeight.
  ///
  /// In en, this message translates to:
  /// **'Line Height'**
  String get lineHeight;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewText.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog. This is a preview of how your articles will look with the current font size and line height settings. Adjust the sliders above to find your preferred reading experience.'**
  String get previewText;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @autoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto-Refresh'**
  String get autoRefresh;

  /// No description provided for @autoRefreshInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto-Refresh Interval'**
  String get autoRefreshInterval;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @contentExpiry.
  ///
  /// In en, this message translates to:
  /// **'Content Expiry'**
  String get contentExpiry;

  /// No description provided for @contentExpiryDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically hide old articles'**
  String get contentExpiryDesc;

  /// No description provided for @cacheImages.
  ///
  /// In en, this message translates to:
  /// **'Cache Images'**
  String get cacheImages;

  /// No description provided for @cacheImagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save images for offline reading'**
  String get cacheImagesDesc;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get importExport;

  /// No description provided for @importOpml.
  ///
  /// In en, this message translates to:
  /// **'Import OPML'**
  String get importOpml;

  /// No description provided for @importOpmlDesc.
  ///
  /// In en, this message translates to:
  /// **'Import subscriptions from an OPML file'**
  String get importOpmlDesc;

  /// No description provided for @exportOpml.
  ///
  /// In en, this message translates to:
  /// **'Export OPML'**
  String get exportOpml;

  /// No description provided for @exportOpmlDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all subscriptions as OPML 2.0'**
  String get exportOpmlDesc;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all feeds, articles, and settings'**
  String get clearAllDataDesc;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAllDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllDataConfirmTitle;

  /// No description provided for @clearAllDataConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all feeds, articles, tags, and settings. This action cannot be undone.'**
  String get clearAllDataConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @refreshIntervalMin.
  ///
  /// In en, this message translates to:
  /// **'{minutes}min'**
  String refreshIntervalMin(int minutes);

  /// No description provided for @refreshIntervalHour.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String refreshIntervalHour(int hours);

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// No description provided for @monthCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String monthCount(int count);

  /// No description provided for @yearCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String yearCount(int count);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A beautiful RSS reader built with Flutter'**
  String get appDescription;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get sourceCode;

  /// No description provided for @viewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGithub;

  /// No description provided for @acknowledgments.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgments'**
  String get acknowledgments;

  /// No description provided for @flutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get flutter;

  /// No description provided for @flutterDesc.
  ///
  /// In en, this message translates to:
  /// **'UI framework by Google'**
  String get flutterDesc;

  /// No description provided for @riverpod.
  ///
  /// In en, this message translates to:
  /// **'Riverpod'**
  String get riverpod;

  /// No description provided for @riverpodDesc.
  ///
  /// In en, this message translates to:
  /// **'State management'**
  String get riverpodDesc;

  /// No description provided for @isar.
  ///
  /// In en, this message translates to:
  /// **'Isar'**
  String get isar;

  /// No description provided for @isarDesc.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get isarDesc;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @madeWithFlutter.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤ using Flutter'**
  String get madeWithFlutter;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @podcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get podcasts;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @feeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get feeds;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get newFolder;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get newTag;

  /// No description provided for @newFilter.
  ///
  /// In en, this message translates to:
  /// **'New Filter'**
  String get newFilter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @addFeed.
  ///
  /// In en, this message translates to:
  /// **'Add Feed'**
  String get addFeed;

  /// No description provided for @enterFeedUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter feed or website URL'**
  String get enterFeedUrl;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @foundFeeds.
  ///
  /// In en, this message translates to:
  /// **'Found {count} feed(s):'**
  String foundFeeds(int count);

  /// No description provided for @pleaseEnterUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL'**
  String get pleaseEnterUrl;

  /// No description provided for @noFeedsFound.
  ///
  /// In en, this message translates to:
  /// **'No feeds found at this URL'**
  String get noFeedsFound;

  /// No description provided for @errorDiscoveringFeeds.
  ///
  /// In en, this message translates to:
  /// **'Error discovering feeds: {error}'**
  String errorDiscoveringFeeds(String error);

  /// No description provided for @discoverFeeds.
  ///
  /// In en, this message translates to:
  /// **'Discover Feeds'**
  String get discoverFeeds;

  /// No description provided for @feedItemsInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {type}'**
  String feedItemsInfo(int count, String type);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browser;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchArticles;

  /// No description provided for @searchYourArticles.
  ///
  /// In en, this message translates to:
  /// **'Search your articles'**
  String get searchYourArticles;

  /// No description provided for @searchByTitleContentAuthor.
  ///
  /// In en, this message translates to:
  /// **'Search by title, content, or author.'**
  String get searchByTitleContentAuthor;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords.'**
  String get tryDifferentKeywords;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(String error);

  /// No description provided for @unknownEpisode.
  ///
  /// In en, this message translates to:
  /// **'Unknown Episode'**
  String get unknownEpisode;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @noEpisodePlaying.
  ///
  /// In en, this message translates to:
  /// **'No episode playing'**
  String get noEpisodePlaying;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'CHAPTERS'**
  String get chapters;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @failedToPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to play video'**
  String get failedToPlayVideo;

  /// No description provided for @unableToPlayVideo.
  ///
  /// In en, this message translates to:
  /// **'Unable to play video'**
  String get unableToPlayVideo;

  /// No description provided for @loadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get loadingVideo;

  /// No description provided for @editFilter.
  ///
  /// In en, this message translates to:
  /// **'Edit Filter'**
  String get editFilter;

  /// No description provided for @newFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'New Filter'**
  String get newFilterTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Filter name'**
  String get filterName;

  /// No description provided for @includeKeywords.
  ///
  /// In en, this message translates to:
  /// **'Include Keywords'**
  String get includeKeywords;

  /// No description provided for @includeKeywordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Items must contain at least one of these keywords.'**
  String get includeKeywordsDesc;

  /// No description provided for @excludeKeywords.
  ///
  /// In en, this message translates to:
  /// **'Exclude Keywords'**
  String get excludeKeywords;

  /// No description provided for @excludeKeywordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Items containing any of these keywords will be filtered out.'**
  String get excludeKeywordsDesc;

  /// No description provided for @contentTypes.
  ///
  /// In en, this message translates to:
  /// **'Content Types'**
  String get contentTypes;

  /// No description provided for @contentTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to include all content types.'**
  String get contentTypesDesc;

  /// No description provided for @feedTypes.
  ///
  /// In en, this message translates to:
  /// **'Feed Types'**
  String get feedTypes;

  /// No description provided for @feedTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to include all feed types.'**
  String get feedTypesDesc;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @matchWholeWords.
  ///
  /// In en, this message translates to:
  /// **'Match Whole Words'**
  String get matchWholeWords;

  /// No description provided for @matchWholeWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Only match complete words, not partial matches.'**
  String get matchWholeWordsDesc;

  /// No description provided for @addKeyword.
  ///
  /// In en, this message translates to:
  /// **'Add keyword...'**
  String get addKeyword;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @blog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get blog;

  /// No description provided for @podcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get podcast;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @deleteFilter.
  ///
  /// In en, this message translates to:
  /// **'Delete Filter'**
  String get deleteFilter;

  /// No description provided for @deleteFilterConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteFilterConfirm(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pleaseEnterFilterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a filter name.'**
  String get pleaseEnterFilterName;

  /// No description provided for @failedToSaveFilter.
  ///
  /// In en, this message translates to:
  /// **'Failed to save filter: {error}'**
  String failedToSaveFilter(String error);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkYourConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get checkYourConnection;

  /// No description provided for @failedToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get failedToLoadFeed;

  /// No description provided for @failedToParseContent.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse content'**
  String get failedToParseContent;

  /// No description provided for @feedFormatNotSupported.
  ///
  /// In en, this message translates to:
  /// **'The feed format may not be supported'**
  String get feedFormatNotSupported;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noArticlesYet.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get noArticlesYet;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh or add a new feed'**
  String get pullDownToRefresh;

  /// No description provided for @noFeedsYet.
  ///
  /// In en, this message translates to:
  /// **'No feeds yet'**
  String get noFeedsYet;

  /// No description provided for @addFeedToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Add your first RSS feed to get started'**
  String get addFeedToGetStarted;

  /// No description provided for @noTaggedItems.
  ///
  /// In en, this message translates to:
  /// **'No tagged items'**
  String get noTaggedItems;

  /// No description provided for @tagArticlesToFindHere.
  ///
  /// In en, this message translates to:
  /// **'Tag articles to find them here'**
  String get tagArticlesToFindHere;

  /// No description provided for @feedSettings.
  ///
  /// In en, this message translates to:
  /// **'Feed Settings'**
  String get feedSettings;

  /// No description provided for @defaultViewer.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT VIEWER'**
  String get defaultViewer;

  /// No description provided for @articleViewer.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get articleViewer;

  /// No description provided for @readerView.
  ///
  /// In en, this message translates to:
  /// **'Reader View'**
  String get readerView;

  /// No description provided for @autoReaderView.
  ///
  /// In en, this message translates to:
  /// **'Auto Reader View'**
  String get autoReaderView;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get moveTo;

  /// No description provided for @noFolder.
  ///
  /// In en, this message translates to:
  /// **'No Folder'**
  String get noFolder;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @unsubscribeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unsubscribe from \"{name}\"? All articles from this feed will be deleted.'**
  String unsubscribeConfirm(String name);

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagName;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get renameFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get deleteFolder;

  /// No description provided for @deleteFolderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Feeds in this folder will be moved to the root level.'**
  String deleteFolderConfirm(String name);

  /// No description provided for @renameTag.
  ///
  /// In en, this message translates to:
  /// **'Rename Tag'**
  String get renameTag;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTag;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All tag associations will be removed.'**
  String deleteTagConfirm(String name);

  /// No description provided for @refreshFeed.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshFeed;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @syncAccounts.
  ///
  /// In en, this message translates to:
  /// **'Sync Accounts'**
  String get syncAccounts;

  /// No description provided for @syncAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage sync service accounts'**
  String get syncAccountsDesc;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @noSyncAccounts.
  ///
  /// In en, this message translates to:
  /// **'No sync accounts configured'**
  String get noSyncAccounts;

  /// No description provided for @timelineSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineSettingsTitle;

  /// No description provided for @sortOrderSection.
  ///
  /// In en, this message translates to:
  /// **'SORT ORDER'**
  String get sortOrderSection;

  /// No description provided for @behaviorSection.
  ///
  /// In en, this message translates to:
  /// **'BEHAVIOR'**
  String get behaviorSection;

  /// No description provided for @contentExpirySection.
  ///
  /// In en, this message translates to:
  /// **'CONTENT EXPIRY'**
  String get contentExpirySection;

  /// No description provided for @groupByFeed.
  ///
  /// In en, this message translates to:
  /// **'Group by Feed'**
  String get groupByFeed;

  /// No description provided for @groupByFeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Group articles by their source feed'**
  String get groupByFeedDesc;

  /// No description provided for @contentExpiryHint.
  ///
  /// In en, this message translates to:
  /// **'Articles older than the selected period will be hidden from timelines. They can still be found via search.'**
  String get contentExpiryHint;

  /// No description provided for @oneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get oneWeek;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'2 Weeks'**
  String get twoWeeks;

  /// No description provided for @oneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get oneMonth;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get failedToLoadSettings;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the {serviceName} account ({detail})? This action cannot be undone.'**
  String deleteAccountConfirm(String serviceName, String detail);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSynced(String time);

  /// No description provided for @neverSynced.
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get neverSynced;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get thirdPartyServices;

  /// No description provided for @selfHostedServices.
  ///
  /// In en, this message translates to:
  /// **'Self-Hosted Services'**
  String get selfHostedServices;

  /// No description provided for @feedbinDesc.
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get feedbinDesc;

  /// No description provided for @feedlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your account'**
  String get feedlyDesc;

  /// No description provided for @inoreaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your account'**
  String get inoreaderDesc;

  /// No description provided for @freshRssDesc.
  ///
  /// In en, this message translates to:
  /// **'Server URL, username & password'**
  String get freshRssDesc;

  /// No description provided for @readerDesc.
  ///
  /// In en, this message translates to:
  /// **'Server URL, username & password'**
  String get readerDesc;

  /// No description provided for @signInWith.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {service}'**
  String signInWith(String service);

  /// No description provided for @signInDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your {service} account to sync your subscriptions and reading progress.'**
  String signInDesc(String service);

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://reader.example.com'**
  String get serverUrlHint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL starting with http:// or https://'**
  String get invalidServerUrl;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @oauthNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'OAuth sign-in for {service} is not yet configured. Please use a service that supports username & password login.'**
  String oauthNotConfigured(String service);

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get accountUpdated;

  /// No description provided for @verifyingCredentials.
  ///
  /// In en, this message translates to:
  /// **'Verifying credentials…'**
  String get verifyingCredentials;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Refreshing subscriptions…'**
  String get loginSuccess;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please check your credentials.'**
  String get authenticationFailed;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// No description provided for @unstar.
  ///
  /// In en, this message translates to:
  /// **'Unstar'**
  String get unstar;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark Read'**
  String get markRead;

  /// No description provided for @markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark Unread'**
  String get markUnread;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of {serviceName}?'**
  String logoutConfirm(String serviceName);

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// No description provided for @syncIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get syncIdle;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get syncError;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @scrollToTop.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get scrollToTop;

  /// No description provided for @showReadArticles.
  ///
  /// In en, this message translates to:
  /// **'Show Read Articles'**
  String get showReadArticles;

  /// No description provided for @loadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get loadingMore;

  /// No description provided for @failedToLoadArticles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load articles'**
  String get failedToLoadArticles;

  /// No description provided for @failedToLoadArticle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load article'**
  String get failedToLoadArticle;

  /// No description provided for @timelineAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get timelineAll;

  /// No description provided for @timelineArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get timelineArticles;

  /// No description provided for @timelineFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get timelineFeed;

  /// No description provided for @timelineFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get timelineFolder;

  /// No description provided for @timelineTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get timelineTag;

  /// No description provided for @timelineFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get timelineFilter;

  /// No description provided for @refreshComplete.
  ///
  /// In en, this message translates to:
  /// **'Refresh complete'**
  String get refreshComplete;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed'**
  String get refreshFailed;

  /// No description provided for @opmlImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} feed(s)'**
  String opmlImportSuccess(int count);

  /// No description provided for @opmlImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get opmlImportFailed;

  /// No description provided for @opmlExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get opmlExportFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show notifications for new articles'**
  String get notificationsDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

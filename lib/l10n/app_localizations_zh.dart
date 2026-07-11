// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Reeder';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get compactMode => '紧凑模式';

  @override
  String get compactModeDesc => '不显示缩略图展示文章';

  @override
  String get showThumbnails => '显示缩略图';

  @override
  String get showFeedIcons => '显示订阅源图标';

  @override
  String get reading => '阅读';

  @override
  String get fontSizeAndLineHeight => '字体大小与行高';

  @override
  String get fontSizeAndLineHeightDesc => '自定义阅读体验';

  @override
  String get bionicReading => '仿生阅读';

  @override
  String get bionicReadingDesc => '加粗单词开头以加快阅读速度';

  @override
  String get markAsReadOnScroll => '滚动时标记为已读';

  @override
  String get markAsReadOnScrollDesc => '滚动经过文章时自动标记为已读';

  @override
  String get hideReadArticles => '隐藏已读文章';

  @override
  String get hideReadArticlesDesc => '文章读完后从时间线中移除';

  @override
  String get sortOrder => '排序方式';

  @override
  String get newestFirst => '最新优先';

  @override
  String get oldestFirst => '最旧优先';

  @override
  String get timeline => '时间线';

  @override
  String get timelineDesc => '排序方式、分组、内容过期';

  @override
  String get data => '数据';

  @override
  String get dataAndStorage => '数据与存储';

  @override
  String get dataAndStorageDesc => '缓存、刷新、导入/导出';

  @override
  String get about => '关于';

  @override
  String get aboutReeder => '关于 Reeder';

  @override
  String get resetAllSettings => '重置所有设置';

  @override
  String get reset => '重置';

  @override
  String get themeLight => '浅色';

  @override
  String get themeLightDesc => '简洁的白色背景';

  @override
  String get themeDark => '深色';

  @override
  String get themeDarkDesc => '保护眼睛';

  @override
  String get themeOled => 'OLED 纯黑';

  @override
  String get themeOledDesc => '适用于 OLED 屏幕的纯黑模式';

  @override
  String get themeDarkLight => '深浅混合';

  @override
  String get themeDarkLightDesc => '深色列表，浅色阅读视图';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeSystemDesc => '跟随系统外观设置';

  @override
  String get automatic => '自动';

  @override
  String get fontSize => '字体大小';

  @override
  String get lineHeight => '行高';

  @override
  String get preview => '预览';

  @override
  String get previewText =>
      '天地玄黄，宇宙洪荒。这是一段预览文本，展示当前字体大小和行高设置下文章的显示效果。请调整上方的滑块以找到您偏好的阅读体验。';

  @override
  String get refresh => '刷新';

  @override
  String get autoRefresh => '自动刷新';

  @override
  String get autoRefreshInterval => '自动刷新间隔';

  @override
  String get content => '内容';

  @override
  String get contentExpiry => '内容过期';

  @override
  String get contentExpiryDesc => '自动隐藏旧文章';

  @override
  String get cacheImages => '缓存图片';

  @override
  String get cacheImagesDesc => '保存图片以供离线阅读';

  @override
  String get importExport => '导入 / 导出';

  @override
  String get importOpml => '导入 OPML';

  @override
  String get importOpmlDesc => '从 OPML 文件导入订阅';

  @override
  String get exportOpml => '导出 OPML';

  @override
  String get exportOpmlDesc => '将所有订阅导出为 OPML 2.0';

  @override
  String get dangerZone => '危险操作';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearAllDataDesc => '删除所有订阅源、文章和设置';

  @override
  String get clear => '清除';

  @override
  String get clearAllDataConfirmTitle => '清除所有数据';

  @override
  String get clearAllDataConfirmMessage => '这将永久删除所有订阅源、文章、标签和设置。此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get clearAll => '全部清除';

  @override
  String get manual => '手动';

  @override
  String refreshIntervalMin(int minutes) {
    return '$minutes分钟';
  }

  @override
  String refreshIntervalHour(int hours) {
    return '$hours小时';
  }

  @override
  String get never => '永不';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String monthCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个月',
    );
    return '$_temp0';
  }

  @override
  String yearCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 年',
    );
    return '$_temp0';
  }

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get appDescription => '使用 Flutter 构建的精美 RSS 阅读器';

  @override
  String get links => '链接';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get sourceCode => '源代码';

  @override
  String get viewOnGithub => '在 GitHub 上查看';

  @override
  String get acknowledgments => '致谢';

  @override
  String get flutter => 'Flutter';

  @override
  String get flutterDesc => 'Google 出品的 UI 框架';

  @override
  String get riverpod => 'Riverpod';

  @override
  String get riverpodDesc => '状态管理';

  @override
  String get isar => 'Isar';

  @override
  String get isarDesc => '本地数据库';

  @override
  String get openSourceLicenses => '开源许可证';

  @override
  String get madeWithFlutter => '使用 Flutter 用 ❤ 制作';

  @override
  String get home => '首页';

  @override
  String get all => '全部';

  @override
  String get articles => '文章';

  @override
  String get podcasts => '播客';

  @override
  String get videos => '视频';

  @override
  String get feeds => '订阅源';

  @override
  String get tags => '标签';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get newTag => '新建标签';

  @override
  String get newFilter => '新建过滤器';

  @override
  String get filters => '过滤器';

  @override
  String get addFeed => '添加订阅';

  @override
  String get enterFeedUrl => '输入订阅源或网站 URL';

  @override
  String get searching => '搜索中...';

  @override
  String foundFeeds(int count) {
    return '找到 $count 个订阅源：';
  }

  @override
  String get pleaseEnterUrl => '请输入 URL';

  @override
  String get noFeedsFound => '未在此 URL 找到订阅源';

  @override
  String errorDiscoveringFeeds(String error) {
    return '发现订阅源时出错：$error';
  }

  @override
  String get discoverFeeds => '发现订阅源';

  @override
  String feedItemsInfo(int count, String type) {
    return '$count 条内容 · $type';
  }

  @override
  String get later => '稍后阅读';

  @override
  String get bookmark => '书签';

  @override
  String get favorite => '收藏';

  @override
  String get share => '分享';

  @override
  String get browser => '浏览器';

  @override
  String get search => '搜索';

  @override
  String get searchArticles => '搜索文章...';

  @override
  String get searchYourArticles => '搜索您的文章';

  @override
  String get searchByTitleContentAuthor => '按标题、内容或作者搜索。';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get tryDifferentKeywords => '尝试不同的关键词。';

  @override
  String searchError(String error) {
    return '搜索错误：$error';
  }

  @override
  String get unknownEpisode => '未知节目';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get noEpisodePlaying => '没有正在播放的节目';

  @override
  String get chapters => '章节';

  @override
  String get video => '视频';

  @override
  String get failedToPlayVideo => '视频播放失败';

  @override
  String get unableToPlayVideo => '无法播放视频';

  @override
  String get loadingVideo => '加载视频中...';

  @override
  String get editFilter => '编辑过滤器';

  @override
  String get newFilterTitle => '新建过滤器';

  @override
  String get save => '保存';

  @override
  String get name => '名称';

  @override
  String get filterName => '过滤器名称';

  @override
  String get includeKeywords => '包含关键词';

  @override
  String get includeKeywordsDesc => '内容必须包含以下至少一个关键词。';

  @override
  String get excludeKeywords => '排除关键词';

  @override
  String get excludeKeywordsDesc => '包含以下任一关键词的内容将被过滤。';

  @override
  String get contentTypes => '内容类型';

  @override
  String get contentTypesDesc => '留空则包含所有内容类型。';

  @override
  String get feedTypes => '订阅源类型';

  @override
  String get feedTypesDesc => '留空则包含所有订阅源类型。';

  @override
  String get options => '选项';

  @override
  String get matchWholeWords => '全词匹配';

  @override
  String get matchWholeWordsDesc => '仅匹配完整单词，不匹配部分内容。';

  @override
  String get addKeyword => '添加关键词...';

  @override
  String get article => '文章';

  @override
  String get audio => '音频';

  @override
  String get image => '图片';

  @override
  String get blog => '博客';

  @override
  String get podcast => '播客';

  @override
  String get mixed => '混合';

  @override
  String get deleteFilter => '删除过滤器';

  @override
  String deleteFilterConfirm(String name) {
    return '确定要删除\"$name\"吗？';
  }

  @override
  String get delete => '删除';

  @override
  String get pleaseEnterFilterName => '请输入过滤器名称。';

  @override
  String failedToSaveFilter(String error) {
    return '保存过滤器失败：$error';
  }

  @override
  String get ok => '确定';

  @override
  String get somethingWentWrong => '出了点问题';

  @override
  String get tryAgain => '重试';

  @override
  String get noInternetConnection => '无网络连接';

  @override
  String get checkYourConnection => '请检查网络连接后重试';

  @override
  String get failedToLoadFeed => '加载订阅源失败';

  @override
  String get failedToParseContent => '解析内容失败';

  @override
  String get feedFormatNotSupported => '该订阅源格式可能不受支持';

  @override
  String get retry => '重试';

  @override
  String get noArticlesYet => '暂无文章';

  @override
  String get pullDownToRefresh => '下拉刷新或添加新的订阅源';

  @override
  String get noFeedsYet => '暂无订阅源';

  @override
  String get addFeedToGetStarted => '添加您的第一个 RSS 订阅源以开始使用';

  @override
  String get noTaggedItems => '暂无标记的内容';

  @override
  String get tagArticlesToFindHere => '标记文章后可在此处找到';

  @override
  String get feedSettings => '订阅源设置';

  @override
  String get defaultViewer => '默认查看器';

  @override
  String get articleViewer => '文章';

  @override
  String get readerView => '阅读视图';

  @override
  String get autoReaderView => '自动阅读视图';

  @override
  String get moveTo => '移动到文件夹';

  @override
  String get noFolder => '无文件夹';

  @override
  String get unsubscribe => '取消订阅';

  @override
  String unsubscribeConfirm(String name) {
    return '确定要取消订阅\"$name\"吗？该订阅源的所有文章将被删除。';
  }

  @override
  String get rename => '重命名';

  @override
  String get create => '创建';

  @override
  String get folderName => '文件夹名称';

  @override
  String get tagName => '标签名称';

  @override
  String get renameFolder => '重命名文件夹';

  @override
  String get deleteFolder => '删除文件夹';

  @override
  String deleteFolderConfirm(String name) {
    return '删除\"$name\"？该文件夹中的订阅源将移至根目录。';
  }

  @override
  String get renameTag => '重命名标签';

  @override
  String get deleteTag => '删除标签';

  @override
  String deleteTagConfirm(String name) {
    return '删除\"$name\"？所有标签关联将被移除。';
  }

  @override
  String get refreshFeed => '刷新';

  @override
  String get accounts => '账户';

  @override
  String get syncAccounts => '同步账户';

  @override
  String get syncAccountsDesc => '管理同步服务账户';

  @override
  String get addAccount => '添加账户';

  @override
  String get noSyncAccounts => '未配置同步账户';

  @override
  String get timelineSettingsTitle => '时间线';

  @override
  String get sortOrderSection => '排序方式';

  @override
  String get behaviorSection => '行为';

  @override
  String get contentExpirySection => '内容过期';

  @override
  String get groupByFeed => '按订阅源分组';

  @override
  String get groupByFeedDesc => '按来源订阅源对文章进行分组';

  @override
  String get contentExpiryHint => '超过所选时间段的文章将从时间线中隐藏。仍可通过搜索找到。';

  @override
  String get oneWeek => '1 周';

  @override
  String get twoWeeks => '2 周';

  @override
  String get oneMonth => '1 个月';

  @override
  String get threeMonths => '3 个月';

  @override
  String get sixMonths => '6 个月';

  @override
  String get failedToLoadSettings => '加载设置失败';

  @override
  String get deleteAccount => '删除账户';

  @override
  String deleteAccountConfirm(String serviceName, String detail) {
    return '确定要删除 $serviceName 账户（$detail）吗？此操作无法撤销。';
  }

  @override
  String get active => '活跃';

  @override
  String lastSynced(String time) {
    return '上次同步：$time';
  }

  @override
  String get neverSynced => '从未同步';

  @override
  String get thirdPartyServices => '第三方服务';

  @override
  String get selfHostedServices => '自建服务';

  @override
  String get feedbinDesc => '邮箱和密码';

  @override
  String get feedlyDesc => '使用您的账户登录';

  @override
  String get inoreaderDesc => '使用您的账户登录';

  @override
  String get freshRssDesc => '服务器地址、用户名和密码';

  @override
  String get readerDesc => '服务器地址、用户名和密码';

  @override
  String signInWith(String service) {
    return '使用 $service 登录';
  }

  @override
  String signInDesc(String service) {
    return '登录您的 $service 账户以同步订阅和阅读进度。';
  }

  @override
  String get serverUrl => '服务器地址';

  @override
  String get serverUrlHint => 'https://reader.example.com';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get fieldRequired => '此项为必填';

  @override
  String get invalidServerUrl => '请输入以 http:// 或 https:// 开头的有效地址';

  @override
  String loginFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String oauthNotConfigured(String service) {
    return '$service 的 OAuth 登录尚未配置，请使用支持用户名和密码登录的服务。';
  }

  @override
  String get comingSoon => '即将推出';

  @override
  String get editAccount => '编辑账户';

  @override
  String get saveChanges => '保存更改';

  @override
  String get accountUpdated => '账户更新成功';

  @override
  String get verifyingCredentials => '正在验证凭证…';

  @override
  String get loginSuccess => '登录成功！正在刷新订阅列表…';

  @override
  String get authenticationFailed => '验证失败，请检查您的凭证。';

  @override
  String get star => '收藏';

  @override
  String get unstar => '取消收藏';

  @override
  String get markRead => '标为已读';

  @override
  String get markUnread => '标为未读';

  @override
  String get markAllAsRead => '全部标为已读';

  @override
  String get syncing => '同步中…';

  @override
  String get syncNow => '立即同步';

  @override
  String get logout => '退出登录';

  @override
  String logoutConfirm(String serviceName) {
    return '确定要退出 $serviceName 吗？';
  }

  @override
  String get syncStatus => '同步状态';

  @override
  String get syncIdle => '空闲';

  @override
  String get syncError => '同步出错';

  @override
  String get sync => '同步';

  @override
  String get scrollToTop => '滚动到顶部';

  @override
  String get showReadArticles => '显示已读文章';

  @override
  String get loadingMore => '加载更多…';

  @override
  String get failedToLoadArticles => '加载文章失败';

  @override
  String get failedToLoadArticle => '加载文章失败';

  @override
  String get timelineAll => '全部';

  @override
  String get timelineArticles => '文章';

  @override
  String get timelineFeed => '订阅源';

  @override
  String get timelineFolder => '文件夹';

  @override
  String get timelineTag => '标签';

  @override
  String get timelineFilter => '过滤器';

  @override
  String get refreshComplete => '刷新完成';

  @override
  String get refreshFailed => '刷新失败';

  @override
  String opmlImportSuccess(int count) {
    return '已导入 $count 个订阅';
  }

  @override
  String get opmlImportFailed => '导入失败';

  @override
  String get opmlExportFailed => '导出失败';
}

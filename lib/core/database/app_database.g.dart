// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FeedsTable extends Feeds with TableInfo<$FeedsTable, Feed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _feedUrlMeta =
      const VerificationMeta('feedUrl');
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
      'feed_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _siteUrlMeta =
      const VerificationMeta('siteUrl');
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
      'site_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconUrlMeta =
      const VerificationMeta('iconUrl');
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
      'icon_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<FeedType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<FeedType>($FeedsTable.$convertertype);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastFetchedMeta =
      const VerificationMeta('lastFetched');
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
      'last_fetched', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fetchDurationMsMeta =
      const VerificationMeta('fetchDurationMs');
  @override
  late final GeneratedColumn<int> fetchDurationMs = GeneratedColumn<int>(
      'fetch_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _defaultViewerMeta =
      const VerificationMeta('defaultViewer');
  @override
  late final GeneratedColumnWithTypeConverter<ViewerType, int> defaultViewer =
      GeneratedColumn<int>('default_viewer', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ViewerType>($FeedsTable.$converterdefaultViewer);
  static const VerificationMeta _autoReaderViewMeta =
      const VerificationMeta('autoReaderView');
  @override
  late final GeneratedColumn<bool> autoReaderView = GeneratedColumn<bool>(
      'auto_reader_view', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_reader_view" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalCountMeta =
      const VerificationMeta('totalCount');
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
      'total_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        feedUrl,
        siteUrl,
        iconUrl,
        type,
        folderId,
        sortOrder,
        lastFetched,
        fetchDurationMs,
        defaultViewer,
        autoReaderView,
        notificationsEnabled,
        accountId,
        unreadCount,
        totalCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(Insertable<Feed> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('feed_url')) {
      context.handle(_feedUrlMeta,
          feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta));
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('site_url')) {
      context.handle(_siteUrlMeta,
          siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta));
    }
    if (data.containsKey('icon_url')) {
      context.handle(_iconUrlMeta,
          iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
          _lastFetchedMeta,
          lastFetched.isAcceptableOrUnknown(
              data['last_fetched']!, _lastFetchedMeta));
    }
    if (data.containsKey('fetch_duration_ms')) {
      context.handle(
          _fetchDurationMsMeta,
          fetchDurationMs.isAcceptableOrUnknown(
              data['fetch_duration_ms']!, _fetchDurationMsMeta));
    }
    context.handle(_defaultViewerMeta, const VerificationResult.success());
    if (data.containsKey('auto_reader_view')) {
      context.handle(
          _autoReaderViewMeta,
          autoReaderView.isAcceptableOrUnknown(
              data['auto_reader_view']!, _autoReaderViewMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('total_count')) {
      context.handle(
          _totalCountMeta,
          totalCount.isAcceptableOrUnknown(
              data['total_count']!, _totalCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Feed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Feed(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      feedUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_url'])!,
      siteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}site_url']),
      iconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_url']),
      type: $FeedsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      lastFetched: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_fetched']),
      fetchDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fetch_duration_ms']),
      defaultViewer: $FeedsTable.$converterdefaultViewer.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}default_viewer'])!),
      autoReaderView: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_reader_view'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      totalCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FeedType, int, int> $convertertype =
      const EnumIndexConverter<FeedType>(FeedType.values);
  static JsonTypeConverter2<ViewerType, int, int> $converterdefaultViewer =
      const EnumIndexConverter<ViewerType>(ViewerType.values);
}

class Feed extends DataClass implements Insertable<Feed> {
  final int id;
  final String title;
  final String? description;
  final String feedUrl;
  final String? siteUrl;
  final String? iconUrl;
  final FeedType type;
  final int? folderId;
  final int sortOrder;
  final DateTime? lastFetched;
  final int? fetchDurationMs;
  final ViewerType defaultViewer;
  final bool autoReaderView;
  final bool notificationsEnabled;
  final int? accountId;
  final int unreadCount;
  final int totalCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Feed(
      {required this.id,
      required this.title,
      this.description,
      required this.feedUrl,
      this.siteUrl,
      this.iconUrl,
      required this.type,
      this.folderId,
      required this.sortOrder,
      this.lastFetched,
      this.fetchDurationMs,
      required this.defaultViewer,
      required this.autoReaderView,
      required this.notificationsEnabled,
      this.accountId,
      required this.unreadCount,
      required this.totalCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['feed_url'] = Variable<String>(feedUrl);
    if (!nullToAbsent || siteUrl != null) {
      map['site_url'] = Variable<String>(siteUrl);
    }
    if (!nullToAbsent || iconUrl != null) {
      map['icon_url'] = Variable<String>(iconUrl);
    }
    {
      map['type'] = Variable<int>($FeedsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || lastFetched != null) {
      map['last_fetched'] = Variable<DateTime>(lastFetched);
    }
    if (!nullToAbsent || fetchDurationMs != null) {
      map['fetch_duration_ms'] = Variable<int>(fetchDurationMs);
    }
    {
      map['default_viewer'] = Variable<int>(
          $FeedsTable.$converterdefaultViewer.toSql(defaultViewer));
    }
    map['auto_reader_view'] = Variable<bool>(autoReaderView);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['unread_count'] = Variable<int>(unreadCount);
    map['total_count'] = Variable<int>(totalCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      feedUrl: Value(feedUrl),
      siteUrl: siteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(siteUrl),
      iconUrl: iconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iconUrl),
      type: Value(type),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      sortOrder: Value(sortOrder),
      lastFetched: lastFetched == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetched),
      fetchDurationMs: fetchDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchDurationMs),
      defaultViewer: Value(defaultViewer),
      autoReaderView: Value(autoReaderView),
      notificationsEnabled: Value(notificationsEnabled),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      unreadCount: Value(unreadCount),
      totalCount: Value(totalCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Feed.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Feed(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      siteUrl: serializer.fromJson<String?>(json['siteUrl']),
      iconUrl: serializer.fromJson<String?>(json['iconUrl']),
      type: $FeedsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      folderId: serializer.fromJson<int?>(json['folderId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      lastFetched: serializer.fromJson<DateTime?>(json['lastFetched']),
      fetchDurationMs: serializer.fromJson<int?>(json['fetchDurationMs']),
      defaultViewer: $FeedsTable.$converterdefaultViewer
          .fromJson(serializer.fromJson<int>(json['defaultViewer'])),
      autoReaderView: serializer.fromJson<bool>(json['autoReaderView']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'siteUrl': serializer.toJson<String?>(siteUrl),
      'iconUrl': serializer.toJson<String?>(iconUrl),
      'type': serializer.toJson<int>($FeedsTable.$convertertype.toJson(type)),
      'folderId': serializer.toJson<int?>(folderId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'lastFetched': serializer.toJson<DateTime?>(lastFetched),
      'fetchDurationMs': serializer.toJson<int?>(fetchDurationMs),
      'defaultViewer': serializer.toJson<int>(
          $FeedsTable.$converterdefaultViewer.toJson(defaultViewer)),
      'autoReaderView': serializer.toJson<bool>(autoReaderView),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'accountId': serializer.toJson<int?>(accountId),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'totalCount': serializer.toJson<int>(totalCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Feed copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          String? feedUrl,
          Value<String?> siteUrl = const Value.absent(),
          Value<String?> iconUrl = const Value.absent(),
          FeedType? type,
          Value<int?> folderId = const Value.absent(),
          int? sortOrder,
          Value<DateTime?> lastFetched = const Value.absent(),
          Value<int?> fetchDurationMs = const Value.absent(),
          ViewerType? defaultViewer,
          bool? autoReaderView,
          bool? notificationsEnabled,
          Value<int?> accountId = const Value.absent(),
          int? unreadCount,
          int? totalCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Feed(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        feedUrl: feedUrl ?? this.feedUrl,
        siteUrl: siteUrl.present ? siteUrl.value : this.siteUrl,
        iconUrl: iconUrl.present ? iconUrl.value : this.iconUrl,
        type: type ?? this.type,
        folderId: folderId.present ? folderId.value : this.folderId,
        sortOrder: sortOrder ?? this.sortOrder,
        lastFetched: lastFetched.present ? lastFetched.value : this.lastFetched,
        fetchDurationMs: fetchDurationMs.present
            ? fetchDurationMs.value
            : this.fetchDurationMs,
        defaultViewer: defaultViewer ?? this.defaultViewer,
        autoReaderView: autoReaderView ?? this.autoReaderView,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        accountId: accountId.present ? accountId.value : this.accountId,
        unreadCount: unreadCount ?? this.unreadCount,
        totalCount: totalCount ?? this.totalCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Feed copyWithCompanion(FeedsCompanion data) {
    return Feed(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      siteUrl: data.siteUrl.present ? data.siteUrl.value : this.siteUrl,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      type: data.type.present ? data.type.value : this.type,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      lastFetched:
          data.lastFetched.present ? data.lastFetched.value : this.lastFetched,
      fetchDurationMs: data.fetchDurationMs.present
          ? data.fetchDurationMs.value
          : this.fetchDurationMs,
      defaultViewer: data.defaultViewer.present
          ? data.defaultViewer.value
          : this.defaultViewer,
      autoReaderView: data.autoReaderView.present
          ? data.autoReaderView.value
          : this.autoReaderView,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      totalCount:
          data.totalCount.present ? data.totalCount.value : this.totalCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Feed(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('type: $type, ')
          ..write('folderId: $folderId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('fetchDurationMs: $fetchDurationMs, ')
          ..write('defaultViewer: $defaultViewer, ')
          ..write('autoReaderView: $autoReaderView, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('accountId: $accountId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      feedUrl,
      siteUrl,
      iconUrl,
      type,
      folderId,
      sortOrder,
      lastFetched,
      fetchDurationMs,
      defaultViewer,
      autoReaderView,
      notificationsEnabled,
      accountId,
      unreadCount,
      totalCount,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Feed &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.feedUrl == this.feedUrl &&
          other.siteUrl == this.siteUrl &&
          other.iconUrl == this.iconUrl &&
          other.type == this.type &&
          other.folderId == this.folderId &&
          other.sortOrder == this.sortOrder &&
          other.lastFetched == this.lastFetched &&
          other.fetchDurationMs == this.fetchDurationMs &&
          other.defaultViewer == this.defaultViewer &&
          other.autoReaderView == this.autoReaderView &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.accountId == this.accountId &&
          other.unreadCount == this.unreadCount &&
          other.totalCount == this.totalCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedsCompanion extends UpdateCompanion<Feed> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> feedUrl;
  final Value<String?> siteUrl;
  final Value<String?> iconUrl;
  final Value<FeedType> type;
  final Value<int?> folderId;
  final Value<int> sortOrder;
  final Value<DateTime?> lastFetched;
  final Value<int?> fetchDurationMs;
  final Value<ViewerType> defaultViewer;
  final Value<bool> autoReaderView;
  final Value<bool> notificationsEnabled;
  final Value<int?> accountId;
  final Value<int> unreadCount;
  final Value<int> totalCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FeedsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.type = const Value.absent(),
    this.folderId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.fetchDurationMs = const Value.absent(),
    this.defaultViewer = const Value.absent(),
    this.autoReaderView = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.accountId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FeedsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String feedUrl,
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.type = const Value.absent(),
    this.folderId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.fetchDurationMs = const Value.absent(),
    this.defaultViewer = const Value.absent(),
    this.autoReaderView = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.accountId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : title = Value(title),
        feedUrl = Value(feedUrl),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Feed> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? feedUrl,
    Expression<String>? siteUrl,
    Expression<String>? iconUrl,
    Expression<int>? type,
    Expression<int>? folderId,
    Expression<int>? sortOrder,
    Expression<DateTime>? lastFetched,
    Expression<int>? fetchDurationMs,
    Expression<int>? defaultViewer,
    Expression<bool>? autoReaderView,
    Expression<bool>? notificationsEnabled,
    Expression<int>? accountId,
    Expression<int>? unreadCount,
    Expression<int>? totalCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (siteUrl != null) 'site_url': siteUrl,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (type != null) 'type': type,
      if (folderId != null) 'folder_id': folderId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (fetchDurationMs != null) 'fetch_duration_ms': fetchDurationMs,
      if (defaultViewer != null) 'default_viewer': defaultViewer,
      if (autoReaderView != null) 'auto_reader_view': autoReaderView,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (accountId != null) 'account_id': accountId,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (totalCount != null) 'total_count': totalCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FeedsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? feedUrl,
      Value<String?>? siteUrl,
      Value<String?>? iconUrl,
      Value<FeedType>? type,
      Value<int?>? folderId,
      Value<int>? sortOrder,
      Value<DateTime?>? lastFetched,
      Value<int?>? fetchDurationMs,
      Value<ViewerType>? defaultViewer,
      Value<bool>? autoReaderView,
      Value<bool>? notificationsEnabled,
      Value<int?>? accountId,
      Value<int>? unreadCount,
      Value<int>? totalCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return FeedsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      feedUrl: feedUrl ?? this.feedUrl,
      siteUrl: siteUrl ?? this.siteUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      type: type ?? this.type,
      folderId: folderId ?? this.folderId,
      sortOrder: sortOrder ?? this.sortOrder,
      lastFetched: lastFetched ?? this.lastFetched,
      fetchDurationMs: fetchDurationMs ?? this.fetchDurationMs,
      defaultViewer: defaultViewer ?? this.defaultViewer,
      autoReaderView: autoReaderView ?? this.autoReaderView,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      accountId: accountId ?? this.accountId,
      unreadCount: unreadCount ?? this.unreadCount,
      totalCount: totalCount ?? this.totalCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($FeedsTable.$convertertype.toSql(type.value));
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (fetchDurationMs.present) {
      map['fetch_duration_ms'] = Variable<int>(fetchDurationMs.value);
    }
    if (defaultViewer.present) {
      map['default_viewer'] = Variable<int>(
          $FeedsTable.$converterdefaultViewer.toSql(defaultViewer.value));
    }
    if (autoReaderView.present) {
      map['auto_reader_view'] = Variable<bool>(autoReaderView.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('type: $type, ')
          ..write('folderId: $folderId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('fetchDurationMs: $fetchDurationMs, ')
          ..write('defaultViewer: $defaultViewer, ')
          ..write('autoReaderView: $autoReaderView, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('accountId: $accountId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FeedItemsTable extends FeedItems
    with TableInfo<$FeedItemsTable, FeedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
      'feed_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlsMeta =
      const VerificationMeta('imageUrls');
  @override
  late final GeneratedColumn<String> imageUrls = GeneratedColumn<String>(
      'image_urls', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _videoUrlMeta =
      const VerificationMeta('videoUrl');
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
      'video_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioDurationMeta =
      const VerificationMeta('audioDuration');
  @override
  late final GeneratedColumn<int> audioDuration = GeneratedColumn<int>(
      'audio_duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publishedAtMeta =
      const VerificationMeta('publishedAt');
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
      'published_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumnWithTypeConverter<ContentType, int> contentType =
      GeneratedColumn<int>('content_type', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ContentType>($FeedItemsTable.$convertercontentType);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isStarredMeta =
      const VerificationMeta('isStarred');
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
      'is_starred', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_starred" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readingTimeMinutesMeta =
      const VerificationMeta('readingTimeMinutes');
  @override
  late final GeneratedColumn<int> readingTimeMinutes = GeneratedColumn<int>(
      'reading_time_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
      'word_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        feedId,
        title,
        summary,
        content,
        url,
        imageUrl,
        imageUrls,
        audioUrl,
        videoUrl,
        audioDuration,
        author,
        publishedAt,
        fetchedAt,
        contentType,
        isRead,
        isStarred,
        readingTimeMinutes,
        accountId,
        wordCount,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed_items';
  @override
  VerificationContext validateIntegrity(Insertable<FeedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feed_id')) {
      context.handle(_feedIdMeta,
          feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta));
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('image_urls')) {
      context.handle(_imageUrlsMeta,
          imageUrls.isAcceptableOrUnknown(data['image_urls']!, _imageUrlsMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('video_url')) {
      context.handle(_videoUrlMeta,
          videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta));
    }
    if (data.containsKey('audio_duration')) {
      context.handle(
          _audioDurationMeta,
          audioDuration.isAcceptableOrUnknown(
              data['audio_duration']!, _audioDurationMeta));
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('published_at')) {
      context.handle(
          _publishedAtMeta,
          publishedAt.isAcceptableOrUnknown(
              data['published_at']!, _publishedAtMeta));
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    context.handle(_contentTypeMeta, const VerificationResult.success());
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_starred')) {
      context.handle(_isStarredMeta,
          isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta));
    }
    if (data.containsKey('reading_time_minutes')) {
      context.handle(
          _readingTimeMinutesMeta,
          readingTimeMinutes.isAcceptableOrUnknown(
              data['reading_time_minutes']!, _readingTimeMinutesMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      feedId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}feed_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      imageUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_urls']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      videoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_url']),
      audioDuration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}audio_duration']),
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      publishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}published_at'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      contentType: $FeedItemsTable.$convertercontentType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}content_type'])!),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isStarred: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_starred'])!,
      readingTimeMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reading_time_minutes']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_count']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FeedItemsTable createAlias(String alias) {
    return $FeedItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContentType, int, int> $convertercontentType =
      const EnumIndexConverter<ContentType>(ContentType.values);
}

class FeedItem extends DataClass implements Insertable<FeedItem> {
  final int id;
  final int feedId;
  final String title;
  final String? summary;
  final String? content;
  final String url;
  final String? imageUrl;

  /// JSON-serialized list of additional image URLs.
  final String? imageUrls;
  final String? audioUrl;
  final String? videoUrl;
  final int? audioDuration;
  final String? author;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final ContentType contentType;
  final bool isRead;
  final bool isStarred;
  final int? readingTimeMinutes;
  final int? accountId;
  final int? wordCount;
  final DateTime createdAt;
  const FeedItem(
      {required this.id,
      required this.feedId,
      required this.title,
      this.summary,
      this.content,
      required this.url,
      this.imageUrl,
      this.imageUrls,
      this.audioUrl,
      this.videoUrl,
      this.audioDuration,
      this.author,
      required this.publishedAt,
      required this.fetchedAt,
      required this.contentType,
      required this.isRead,
      required this.isStarred,
      this.readingTimeMinutes,
      this.accountId,
      this.wordCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feed_id'] = Variable<int>(feedId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || imageUrls != null) {
      map['image_urls'] = Variable<String>(imageUrls);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || audioDuration != null) {
      map['audio_duration'] = Variable<int>(audioDuration);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    {
      map['content_type'] = Variable<int>(
          $FeedItemsTable.$convertercontentType.toSql(contentType));
    }
    map['is_read'] = Variable<bool>(isRead);
    map['is_starred'] = Variable<bool>(isStarred);
    if (!nullToAbsent || readingTimeMinutes != null) {
      map['reading_time_minutes'] = Variable<int>(readingTimeMinutes);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<int>(wordCount);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeedItemsCompanion toCompanion(bool nullToAbsent) {
    return FeedItemsCompanion(
      id: Value(id),
      feedId: Value(feedId),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      url: Value(url),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      imageUrls: imageUrls == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrls),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      audioDuration: audioDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(audioDuration),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      publishedAt: Value(publishedAt),
      fetchedAt: Value(fetchedAt),
      contentType: Value(contentType),
      isRead: Value(isRead),
      isStarred: Value(isStarred),
      readingTimeMinutes: readingTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(readingTimeMinutes),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      createdAt: Value(createdAt),
    );
  }

  factory FeedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedItem(
      id: serializer.fromJson<int>(json['id']),
      feedId: serializer.fromJson<int>(json['feedId']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      content: serializer.fromJson<String?>(json['content']),
      url: serializer.fromJson<String>(json['url']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      imageUrls: serializer.fromJson<String?>(json['imageUrls']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      audioDuration: serializer.fromJson<int?>(json['audioDuration']),
      author: serializer.fromJson<String?>(json['author']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      contentType: $FeedItemsTable.$convertercontentType
          .fromJson(serializer.fromJson<int>(json['contentType'])),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      readingTimeMinutes: serializer.fromJson<int?>(json['readingTimeMinutes']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      wordCount: serializer.fromJson<int?>(json['wordCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedId': serializer.toJson<int>(feedId),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'content': serializer.toJson<String?>(content),
      'url': serializer.toJson<String>(url),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'imageUrls': serializer.toJson<String?>(imageUrls),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'audioDuration': serializer.toJson<int?>(audioDuration),
      'author': serializer.toJson<String?>(author),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'contentType': serializer.toJson<int>(
          $FeedItemsTable.$convertercontentType.toJson(contentType)),
      'isRead': serializer.toJson<bool>(isRead),
      'isStarred': serializer.toJson<bool>(isStarred),
      'readingTimeMinutes': serializer.toJson<int?>(readingTimeMinutes),
      'accountId': serializer.toJson<int?>(accountId),
      'wordCount': serializer.toJson<int?>(wordCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedItem copyWith(
          {int? id,
          int? feedId,
          String? title,
          Value<String?> summary = const Value.absent(),
          Value<String?> content = const Value.absent(),
          String? url,
          Value<String?> imageUrl = const Value.absent(),
          Value<String?> imageUrls = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          Value<String?> videoUrl = const Value.absent(),
          Value<int?> audioDuration = const Value.absent(),
          Value<String?> author = const Value.absent(),
          DateTime? publishedAt,
          DateTime? fetchedAt,
          ContentType? contentType,
          bool? isRead,
          bool? isStarred,
          Value<int?> readingTimeMinutes = const Value.absent(),
          Value<int?> accountId = const Value.absent(),
          Value<int?> wordCount = const Value.absent(),
          DateTime? createdAt}) =>
      FeedItem(
        id: id ?? this.id,
        feedId: feedId ?? this.feedId,
        title: title ?? this.title,
        summary: summary.present ? summary.value : this.summary,
        content: content.present ? content.value : this.content,
        url: url ?? this.url,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        imageUrls: imageUrls.present ? imageUrls.value : this.imageUrls,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
        audioDuration:
            audioDuration.present ? audioDuration.value : this.audioDuration,
        author: author.present ? author.value : this.author,
        publishedAt: publishedAt ?? this.publishedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        contentType: contentType ?? this.contentType,
        isRead: isRead ?? this.isRead,
        isStarred: isStarred ?? this.isStarred,
        readingTimeMinutes: readingTimeMinutes.present
            ? readingTimeMinutes.value
            : this.readingTimeMinutes,
        accountId: accountId.present ? accountId.value : this.accountId,
        wordCount: wordCount.present ? wordCount.value : this.wordCount,
        createdAt: createdAt ?? this.createdAt,
      );
  FeedItem copyWithCompanion(FeedItemsCompanion data) {
    return FeedItem(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      content: data.content.present ? data.content.value : this.content,
      url: data.url.present ? data.url.value : this.url,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      audioDuration: data.audioDuration.present
          ? data.audioDuration.value
          : this.audioDuration,
      author: data.author.present ? data.author.value : this.author,
      publishedAt:
          data.publishedAt.present ? data.publishedAt.value : this.publishedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      readingTimeMinutes: data.readingTimeMinutes.present
          ? data.readingTimeMinutes.value
          : this.readingTimeMinutes,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedItem(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('audioDuration: $audioDuration, ')
          ..write('author: $author, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('contentType: $contentType, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('readingTimeMinutes: $readingTimeMinutes, ')
          ..write('accountId: $accountId, ')
          ..write('wordCount: $wordCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        feedId,
        title,
        summary,
        content,
        url,
        imageUrl,
        imageUrls,
        audioUrl,
        videoUrl,
        audioDuration,
        author,
        publishedAt,
        fetchedAt,
        contentType,
        isRead,
        isStarred,
        readingTimeMinutes,
        accountId,
        wordCount,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedItem &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.content == this.content &&
          other.url == this.url &&
          other.imageUrl == this.imageUrl &&
          other.imageUrls == this.imageUrls &&
          other.audioUrl == this.audioUrl &&
          other.videoUrl == this.videoUrl &&
          other.audioDuration == this.audioDuration &&
          other.author == this.author &&
          other.publishedAt == this.publishedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.contentType == this.contentType &&
          other.isRead == this.isRead &&
          other.isStarred == this.isStarred &&
          other.readingTimeMinutes == this.readingTimeMinutes &&
          other.accountId == this.accountId &&
          other.wordCount == this.wordCount &&
          other.createdAt == this.createdAt);
}

class FeedItemsCompanion extends UpdateCompanion<FeedItem> {
  final Value<int> id;
  final Value<int> feedId;
  final Value<String> title;
  final Value<String?> summary;
  final Value<String?> content;
  final Value<String> url;
  final Value<String?> imageUrl;
  final Value<String?> imageUrls;
  final Value<String?> audioUrl;
  final Value<String?> videoUrl;
  final Value<int?> audioDuration;
  final Value<String?> author;
  final Value<DateTime> publishedAt;
  final Value<DateTime> fetchedAt;
  final Value<ContentType> contentType;
  final Value<bool> isRead;
  final Value<bool> isStarred;
  final Value<int?> readingTimeMinutes;
  final Value<int?> accountId;
  final Value<int?> wordCount;
  final Value<DateTime> createdAt;
  const FeedItemsCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.content = const Value.absent(),
    this.url = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.audioDuration = const Value.absent(),
    this.author = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.contentType = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.readingTimeMinutes = const Value.absent(),
    this.accountId = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FeedItemsCompanion.insert({
    this.id = const Value.absent(),
    required int feedId,
    required String title,
    this.summary = const Value.absent(),
    this.content = const Value.absent(),
    required String url,
    this.imageUrl = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.audioDuration = const Value.absent(),
    this.author = const Value.absent(),
    required DateTime publishedAt,
    required DateTime fetchedAt,
    this.contentType = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.readingTimeMinutes = const Value.absent(),
    this.accountId = const Value.absent(),
    this.wordCount = const Value.absent(),
    required DateTime createdAt,
  })  : feedId = Value(feedId),
        title = Value(title),
        url = Value(url),
        publishedAt = Value(publishedAt),
        fetchedAt = Value(fetchedAt),
        createdAt = Value(createdAt);
  static Insertable<FeedItem> custom({
    Expression<int>? id,
    Expression<int>? feedId,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? content,
    Expression<String>? url,
    Expression<String>? imageUrl,
    Expression<String>? imageUrls,
    Expression<String>? audioUrl,
    Expression<String>? videoUrl,
    Expression<int>? audioDuration,
    Expression<String>? author,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? fetchedAt,
    Expression<int>? contentType,
    Expression<bool>? isRead,
    Expression<bool>? isStarred,
    Expression<int>? readingTimeMinutes,
    Expression<int>? accountId,
    Expression<int>? wordCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (content != null) 'content': content,
      if (url != null) 'url': url,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (audioDuration != null) 'audio_duration': audioDuration,
      if (author != null) 'author': author,
      if (publishedAt != null) 'published_at': publishedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (contentType != null) 'content_type': contentType,
      if (isRead != null) 'is_read': isRead,
      if (isStarred != null) 'is_starred': isStarred,
      if (readingTimeMinutes != null)
        'reading_time_minutes': readingTimeMinutes,
      if (accountId != null) 'account_id': accountId,
      if (wordCount != null) 'word_count': wordCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FeedItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? feedId,
      Value<String>? title,
      Value<String?>? summary,
      Value<String?>? content,
      Value<String>? url,
      Value<String?>? imageUrl,
      Value<String?>? imageUrls,
      Value<String?>? audioUrl,
      Value<String?>? videoUrl,
      Value<int?>? audioDuration,
      Value<String?>? author,
      Value<DateTime>? publishedAt,
      Value<DateTime>? fetchedAt,
      Value<ContentType>? contentType,
      Value<bool>? isRead,
      Value<bool>? isStarred,
      Value<int?>? readingTimeMinutes,
      Value<int?>? accountId,
      Value<int?>? wordCount,
      Value<DateTime>? createdAt}) {
    return FeedItemsCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      contentType: contentType ?? this.contentType,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      accountId: accountId ?? this.accountId,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(imageUrls.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (audioDuration.present) {
      map['audio_duration'] = Variable<int>(audioDuration.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<int>(
          $FeedItemsTable.$convertercontentType.toSql(contentType.value));
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (readingTimeMinutes.present) {
      map['reading_time_minutes'] = Variable<int>(readingTimeMinutes.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedItemsCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('content: $content, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('audioDuration: $audioDuration, ')
          ..write('author: $author, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('contentType: $contentType, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('readingTimeMinutes: $readingTimeMinutes, ')
          ..write('accountId: $accountId, ')
          ..write('wordCount: $wordCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isBuiltInMeta =
      const VerificationMeta('isBuiltIn');
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
      'is_built_in', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_built_in" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSharedMeta =
      const VerificationMeta('isShared');
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
      'is_shared', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_shared" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sharedFeedUrlMeta =
      const VerificationMeta('sharedFeedUrl');
  @override
  late final GeneratedColumn<String> sharedFeedUrl = GeneratedColumn<String>(
      'shared_feed_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _itemCountMeta =
      const VerificationMeta('itemCount');
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
      'item_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconName,
        accountId,
        isBuiltIn,
        isShared,
        sharedFeedUrl,
        itemCount,
        sortOrder,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
          _isBuiltInMeta,
          isBuiltIn.isAcceptableOrUnknown(
              data['is_built_in']!, _isBuiltInMeta));
    }
    if (data.containsKey('is_shared')) {
      context.handle(_isSharedMeta,
          isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta));
    }
    if (data.containsKey('shared_feed_url')) {
      context.handle(
          _sharedFeedUrlMeta,
          sharedFeedUrl.isAcceptableOrUnknown(
              data['shared_feed_url']!, _sharedFeedUrlMeta));
    }
    if (data.containsKey('item_count')) {
      context.handle(_itemCountMeta,
          itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      isBuiltIn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_built_in'])!,
      isShared: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_shared'])!,
      sharedFeedUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_feed_url']),
      itemCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_count'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String? iconName;
  final int? accountId;
  final bool isBuiltIn;
  final bool isShared;
  final String? sharedFeedUrl;
  final int itemCount;
  final int sortOrder;
  final DateTime createdAt;
  const Tag(
      {required this.id,
      required this.name,
      this.iconName,
      this.accountId,
      required this.isBuiltIn,
      required this.isShared,
      this.sharedFeedUrl,
      required this.itemCount,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['is_shared'] = Variable<bool>(isShared);
    if (!nullToAbsent || sharedFeedUrl != null) {
      map['shared_feed_url'] = Variable<String>(sharedFeedUrl);
    }
    map['item_count'] = Variable<int>(itemCount);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      isBuiltIn: Value(isBuiltIn),
      isShared: Value(isShared),
      sharedFeedUrl: sharedFeedUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedFeedUrl),
      itemCount: Value(itemCount),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isShared: serializer.fromJson<bool>(json['isShared']),
      sharedFeedUrl: serializer.fromJson<String?>(json['sharedFeedUrl']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'accountId': serializer.toJson<int?>(accountId),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isShared': serializer.toJson<bool>(isShared),
      'sharedFeedUrl': serializer.toJson<String?>(sharedFeedUrl),
      'itemCount': serializer.toJson<int>(itemCount),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tag copyWith(
          {int? id,
          String? name,
          Value<String?> iconName = const Value.absent(),
          Value<int?> accountId = const Value.absent(),
          bool? isBuiltIn,
          bool? isShared,
          Value<String?> sharedFeedUrl = const Value.absent(),
          int? itemCount,
          int? sortOrder,
          DateTime? createdAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName.present ? iconName.value : this.iconName,
        accountId: accountId.present ? accountId.value : this.accountId,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        isShared: isShared ?? this.isShared,
        sharedFeedUrl:
            sharedFeedUrl.present ? sharedFeedUrl.value : this.sharedFeedUrl,
        itemCount: itemCount ?? this.itemCount,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
      sharedFeedUrl: data.sharedFeedUrl.present
          ? data.sharedFeedUrl.value
          : this.sharedFeedUrl,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('accountId: $accountId, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isShared: $isShared, ')
          ..write('sharedFeedUrl: $sharedFeedUrl, ')
          ..write('itemCount: $itemCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, accountId, isBuiltIn,
      isShared, sharedFeedUrl, itemCount, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.accountId == this.accountId &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isShared == this.isShared &&
          other.sharedFeedUrl == this.sharedFeedUrl &&
          other.itemCount == this.itemCount &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iconName;
  final Value<int?> accountId;
  final Value<bool> isBuiltIn;
  final Value<bool> isShared;
  final Value<String?> sharedFeedUrl;
  final Value<int> itemCount;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sharedFeedUrl = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isShared = const Value.absent(),
    this.sharedFeedUrl = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
  })  : name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? accountId,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isShared,
    Expression<String>? sharedFeedUrl,
    Expression<int>? itemCount,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (accountId != null) 'account_id': accountId,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (isShared != null) 'is_shared': isShared,
      if (sharedFeedUrl != null) 'shared_feed_url': sharedFeedUrl,
      if (itemCount != null) 'item_count': itemCount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? iconName,
      Value<int?>? accountId,
      Value<bool>? isBuiltIn,
      Value<bool>? isShared,
      Value<String?>? sharedFeedUrl,
      Value<int>? itemCount,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      accountId: accountId ?? this.accountId,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isShared: isShared ?? this.isShared,
      sharedFeedUrl: sharedFeedUrl ?? this.sharedFeedUrl,
      itemCount: itemCount ?? this.itemCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (sharedFeedUrl.present) {
      map['shared_feed_url'] = Variable<String>(sharedFeedUrl.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('accountId: $accountId, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isShared: $isShared, ')
          ..write('sharedFeedUrl: $sharedFeedUrl, ')
          ..write('itemCount: $itemCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TaggedItemsTable extends TaggedItems
    with TableInfo<$TaggedItemsTable, TaggedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaggedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _taggedAtMeta =
      const VerificationMeta('taggedAt');
  @override
  late final GeneratedColumn<DateTime> taggedAt = GeneratedColumn<DateTime>(
      'tagged_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, tagId, itemId, accountId, taggedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tagged_items';
  @override
  VerificationContext validateIntegrity(Insertable<TaggedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('tagged_at')) {
      context.handle(_taggedAtMeta,
          taggedAt.isAcceptableOrUnknown(data['tagged_at']!, _taggedAtMeta));
    } else if (isInserting) {
      context.missing(_taggedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaggedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaggedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      taggedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tagged_at'])!,
    );
  }

  @override
  $TaggedItemsTable createAlias(String alias) {
    return $TaggedItemsTable(attachedDatabase, alias);
  }
}

class TaggedItem extends DataClass implements Insertable<TaggedItem> {
  final int id;
  final int tagId;
  final int itemId;
  final int? accountId;
  final DateTime taggedAt;
  const TaggedItem(
      {required this.id,
      required this.tagId,
      required this.itemId,
      this.accountId,
      required this.taggedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tag_id'] = Variable<int>(tagId);
    map['item_id'] = Variable<int>(itemId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['tagged_at'] = Variable<DateTime>(taggedAt);
    return map;
  }

  TaggedItemsCompanion toCompanion(bool nullToAbsent) {
    return TaggedItemsCompanion(
      id: Value(id),
      tagId: Value(tagId),
      itemId: Value(itemId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      taggedAt: Value(taggedAt),
    );
  }

  factory TaggedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaggedItem(
      id: serializer.fromJson<int>(json['id']),
      tagId: serializer.fromJson<int>(json['tagId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      taggedAt: serializer.fromJson<DateTime>(json['taggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tagId': serializer.toJson<int>(tagId),
      'itemId': serializer.toJson<int>(itemId),
      'accountId': serializer.toJson<int?>(accountId),
      'taggedAt': serializer.toJson<DateTime>(taggedAt),
    };
  }

  TaggedItem copyWith(
          {int? id,
          int? tagId,
          int? itemId,
          Value<int?> accountId = const Value.absent(),
          DateTime? taggedAt}) =>
      TaggedItem(
        id: id ?? this.id,
        tagId: tagId ?? this.tagId,
        itemId: itemId ?? this.itemId,
        accountId: accountId.present ? accountId.value : this.accountId,
        taggedAt: taggedAt ?? this.taggedAt,
      );
  TaggedItem copyWithCompanion(TaggedItemsCompanion data) {
    return TaggedItem(
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      taggedAt: data.taggedAt.present ? data.taggedAt.value : this.taggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaggedItem(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('itemId: $itemId, ')
          ..write('accountId: $accountId, ')
          ..write('taggedAt: $taggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tagId, itemId, accountId, taggedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaggedItem &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.itemId == this.itemId &&
          other.accountId == this.accountId &&
          other.taggedAt == this.taggedAt);
}

class TaggedItemsCompanion extends UpdateCompanion<TaggedItem> {
  final Value<int> id;
  final Value<int> tagId;
  final Value<int> itemId;
  final Value<int?> accountId;
  final Value<DateTime> taggedAt;
  const TaggedItemsCompanion({
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.taggedAt = const Value.absent(),
  });
  TaggedItemsCompanion.insert({
    this.id = const Value.absent(),
    required int tagId,
    required int itemId,
    this.accountId = const Value.absent(),
    required DateTime taggedAt,
  })  : tagId = Value(tagId),
        itemId = Value(itemId),
        taggedAt = Value(taggedAt);
  static Insertable<TaggedItem> custom({
    Expression<int>? id,
    Expression<int>? tagId,
    Expression<int>? itemId,
    Expression<int>? accountId,
    Expression<DateTime>? taggedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (itemId != null) 'item_id': itemId,
      if (accountId != null) 'account_id': accountId,
      if (taggedAt != null) 'tagged_at': taggedAt,
    });
  }

  TaggedItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? tagId,
      Value<int>? itemId,
      Value<int?>? accountId,
      Value<DateTime>? taggedAt}) {
    return TaggedItemsCompanion(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      itemId: itemId ?? this.itemId,
      accountId: accountId ?? this.accountId,
      taggedAt: taggedAt ?? this.taggedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (taggedAt.present) {
      map['tagged_at'] = Variable<DateTime>(taggedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaggedItemsCompanion(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('itemId: $itemId, ')
          ..write('accountId: $accountId, ')
          ..write('taggedAt: $taggedAt')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isExpandedMeta =
      const VerificationMeta('isExpanded');
  @override
  late final GeneratedColumn<bool> isExpanded = GeneratedColumn<bool>(
      'is_expanded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_expanded" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconName,
        accountId,
        sortOrder,
        isExpanded,
        unreadCount,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(Insertable<Folder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_expanded')) {
      context.handle(
          _isExpandedMeta,
          isExpanded.isAcceptableOrUnknown(
              data['is_expanded']!, _isExpandedMeta));
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isExpanded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_expanded'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;
  final String? iconName;
  final int? accountId;
  final int sortOrder;
  final bool isExpanded;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Folder(
      {required this.id,
      required this.name,
      this.iconName,
      this.accountId,
      required this.sortOrder,
      required this.isExpanded,
      required this.unreadCount,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_expanded'] = Variable<bool>(isExpanded);
    map['unread_count'] = Variable<int>(unreadCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      sortOrder: Value(sortOrder),
      isExpanded: Value(isExpanded),
      unreadCount: Value(unreadCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isExpanded: serializer.fromJson<bool>(json['isExpanded']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'accountId': serializer.toJson<int?>(accountId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isExpanded': serializer.toJson<bool>(isExpanded),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Folder copyWith(
          {int? id,
          String? name,
          Value<String?> iconName = const Value.absent(),
          Value<int?> accountId = const Value.absent(),
          int? sortOrder,
          bool? isExpanded,
          int? unreadCount,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Folder(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName.present ? iconName.value : this.iconName,
        accountId: accountId.present ? accountId.value : this.accountId,
        sortOrder: sortOrder ?? this.sortOrder,
        isExpanded: isExpanded ?? this.isExpanded,
        unreadCount: unreadCount ?? this.unreadCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isExpanded:
          data.isExpanded.present ? data.isExpanded.value : this.isExpanded,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('accountId: $accountId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isExpanded: $isExpanded, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, accountId, sortOrder,
      isExpanded, unreadCount, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.accountId == this.accountId &&
          other.sortOrder == this.sortOrder &&
          other.isExpanded == this.isExpanded &&
          other.unreadCount == this.unreadCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iconName;
  final Value<int?> accountId;
  final Value<int> sortOrder;
  final Value<bool> isExpanded;
  final Value<int> unreadCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isExpanded = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isExpanded = const Value.absent(),
    this.unreadCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? accountId,
    Expression<int>? sortOrder,
    Expression<bool>? isExpanded,
    Expression<int>? unreadCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (accountId != null) 'account_id': accountId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isExpanded != null) 'is_expanded': isExpanded,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoldersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? iconName,
      Value<int?>? accountId,
      Value<int>? sortOrder,
      Value<bool>? isExpanded,
      Value<int>? unreadCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      accountId: accountId ?? this.accountId,
      sortOrder: sortOrder ?? this.sortOrder,
      isExpanded: isExpanded ?? this.isExpanded,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isExpanded.present) {
      map['is_expanded'] = Variable<bool>(isExpanded.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('accountId: $accountId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isExpanded: $isExpanded, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FiltersTable extends Filters with TableInfo<$FiltersTable, Filter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FiltersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _includeKeywordsMeta =
      const VerificationMeta('includeKeywords');
  @override
  late final GeneratedColumn<String> includeKeywords = GeneratedColumn<String>(
      'include_keywords', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _excludeKeywordsMeta =
      const VerificationMeta('excludeKeywords');
  @override
  late final GeneratedColumn<String> excludeKeywords = GeneratedColumn<String>(
      'exclude_keywords', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _mediaTypesMeta =
      const VerificationMeta('mediaTypes');
  @override
  late final GeneratedColumn<String> mediaTypes = GeneratedColumn<String>(
      'media_types', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _feedTypesMeta =
      const VerificationMeta('feedTypes');
  @override
  late final GeneratedColumn<String> feedTypes = GeneratedColumn<String>(
      'feed_types', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _matchWholeWordMeta =
      const VerificationMeta('matchWholeWord');
  @override
  late final GeneratedColumn<bool> matchWholeWord = GeneratedColumn<bool>(
      'match_whole_word', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("match_whole_word" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        accountId,
        includeKeywords,
        excludeKeywords,
        mediaTypes,
        feedTypes,
        matchWholeWord,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'filters';
  @override
  VerificationContext validateIntegrity(Insertable<Filter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('include_keywords')) {
      context.handle(
          _includeKeywordsMeta,
          includeKeywords.isAcceptableOrUnknown(
              data['include_keywords']!, _includeKeywordsMeta));
    }
    if (data.containsKey('exclude_keywords')) {
      context.handle(
          _excludeKeywordsMeta,
          excludeKeywords.isAcceptableOrUnknown(
              data['exclude_keywords']!, _excludeKeywordsMeta));
    }
    if (data.containsKey('media_types')) {
      context.handle(
          _mediaTypesMeta,
          mediaTypes.isAcceptableOrUnknown(
              data['media_types']!, _mediaTypesMeta));
    }
    if (data.containsKey('feed_types')) {
      context.handle(_feedTypesMeta,
          feedTypes.isAcceptableOrUnknown(data['feed_types']!, _feedTypesMeta));
    }
    if (data.containsKey('match_whole_word')) {
      context.handle(
          _matchWholeWordMeta,
          matchWholeWord.isAcceptableOrUnknown(
              data['match_whole_word']!, _matchWholeWordMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Filter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Filter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      includeKeywords: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}include_keywords'])!,
      excludeKeywords: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}exclude_keywords'])!,
      mediaTypes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_types'])!,
      feedTypes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_types'])!,
      matchWholeWord: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}match_whole_word'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FiltersTable createAlias(String alias) {
    return $FiltersTable(attachedDatabase, alias);
  }
}

class Filter extends DataClass implements Insertable<Filter> {
  final int id;
  final String name;
  final int? accountId;

  /// JSON-encoded List<String> of include keywords.
  final String includeKeywords;

  /// JSON-encoded List<String> of exclude keywords.
  final String excludeKeywords;

  /// JSON-encoded List<String> of content types to include.
  final String mediaTypes;

  /// JSON-encoded List<String> of feed types to include.
  final String feedTypes;
  final bool matchWholeWord;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Filter(
      {required this.id,
      required this.name,
      this.accountId,
      required this.includeKeywords,
      required this.excludeKeywords,
      required this.mediaTypes,
      required this.feedTypes,
      required this.matchWholeWord,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['include_keywords'] = Variable<String>(includeKeywords);
    map['exclude_keywords'] = Variable<String>(excludeKeywords);
    map['media_types'] = Variable<String>(mediaTypes);
    map['feed_types'] = Variable<String>(feedTypes);
    map['match_whole_word'] = Variable<bool>(matchWholeWord);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FiltersCompanion toCompanion(bool nullToAbsent) {
    return FiltersCompanion(
      id: Value(id),
      name: Value(name),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      includeKeywords: Value(includeKeywords),
      excludeKeywords: Value(excludeKeywords),
      mediaTypes: Value(mediaTypes),
      feedTypes: Value(feedTypes),
      matchWholeWord: Value(matchWholeWord),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Filter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Filter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      includeKeywords: serializer.fromJson<String>(json['includeKeywords']),
      excludeKeywords: serializer.fromJson<String>(json['excludeKeywords']),
      mediaTypes: serializer.fromJson<String>(json['mediaTypes']),
      feedTypes: serializer.fromJson<String>(json['feedTypes']),
      matchWholeWord: serializer.fromJson<bool>(json['matchWholeWord']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'accountId': serializer.toJson<int?>(accountId),
      'includeKeywords': serializer.toJson<String>(includeKeywords),
      'excludeKeywords': serializer.toJson<String>(excludeKeywords),
      'mediaTypes': serializer.toJson<String>(mediaTypes),
      'feedTypes': serializer.toJson<String>(feedTypes),
      'matchWholeWord': serializer.toJson<bool>(matchWholeWord),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Filter copyWith(
          {int? id,
          String? name,
          Value<int?> accountId = const Value.absent(),
          String? includeKeywords,
          String? excludeKeywords,
          String? mediaTypes,
          String? feedTypes,
          bool? matchWholeWord,
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Filter(
        id: id ?? this.id,
        name: name ?? this.name,
        accountId: accountId.present ? accountId.value : this.accountId,
        includeKeywords: includeKeywords ?? this.includeKeywords,
        excludeKeywords: excludeKeywords ?? this.excludeKeywords,
        mediaTypes: mediaTypes ?? this.mediaTypes,
        feedTypes: feedTypes ?? this.feedTypes,
        matchWholeWord: matchWholeWord ?? this.matchWholeWord,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Filter copyWithCompanion(FiltersCompanion data) {
    return Filter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      includeKeywords: data.includeKeywords.present
          ? data.includeKeywords.value
          : this.includeKeywords,
      excludeKeywords: data.excludeKeywords.present
          ? data.excludeKeywords.value
          : this.excludeKeywords,
      mediaTypes:
          data.mediaTypes.present ? data.mediaTypes.value : this.mediaTypes,
      feedTypes: data.feedTypes.present ? data.feedTypes.value : this.feedTypes,
      matchWholeWord: data.matchWholeWord.present
          ? data.matchWholeWord.value
          : this.matchWholeWord,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Filter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountId: $accountId, ')
          ..write('includeKeywords: $includeKeywords, ')
          ..write('excludeKeywords: $excludeKeywords, ')
          ..write('mediaTypes: $mediaTypes, ')
          ..write('feedTypes: $feedTypes, ')
          ..write('matchWholeWord: $matchWholeWord, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      accountId,
      includeKeywords,
      excludeKeywords,
      mediaTypes,
      feedTypes,
      matchWholeWord,
      sortOrder,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Filter &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountId == this.accountId &&
          other.includeKeywords == this.includeKeywords &&
          other.excludeKeywords == this.excludeKeywords &&
          other.mediaTypes == this.mediaTypes &&
          other.feedTypes == this.feedTypes &&
          other.matchWholeWord == this.matchWholeWord &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FiltersCompanion extends UpdateCompanion<Filter> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> accountId;
  final Value<String> includeKeywords;
  final Value<String> excludeKeywords;
  final Value<String> mediaTypes;
  final Value<String> feedTypes;
  final Value<bool> matchWholeWord;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FiltersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountId = const Value.absent(),
    this.includeKeywords = const Value.absent(),
    this.excludeKeywords = const Value.absent(),
    this.mediaTypes = const Value.absent(),
    this.feedTypes = const Value.absent(),
    this.matchWholeWord = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FiltersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.accountId = const Value.absent(),
    this.includeKeywords = const Value.absent(),
    this.excludeKeywords = const Value.absent(),
    this.mediaTypes = const Value.absent(),
    this.feedTypes = const Value.absent(),
    this.matchWholeWord = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Filter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? accountId,
    Expression<String>? includeKeywords,
    Expression<String>? excludeKeywords,
    Expression<String>? mediaTypes,
    Expression<String>? feedTypes,
    Expression<bool>? matchWholeWord,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountId != null) 'account_id': accountId,
      if (includeKeywords != null) 'include_keywords': includeKeywords,
      if (excludeKeywords != null) 'exclude_keywords': excludeKeywords,
      if (mediaTypes != null) 'media_types': mediaTypes,
      if (feedTypes != null) 'feed_types': feedTypes,
      if (matchWholeWord != null) 'match_whole_word': matchWholeWord,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FiltersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int?>? accountId,
      Value<String>? includeKeywords,
      Value<String>? excludeKeywords,
      Value<String>? mediaTypes,
      Value<String>? feedTypes,
      Value<bool>? matchWholeWord,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return FiltersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      includeKeywords: includeKeywords ?? this.includeKeywords,
      excludeKeywords: excludeKeywords ?? this.excludeKeywords,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      feedTypes: feedTypes ?? this.feedTypes,
      matchWholeWord: matchWholeWord ?? this.matchWholeWord,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (includeKeywords.present) {
      map['include_keywords'] = Variable<String>(includeKeywords.value);
    }
    if (excludeKeywords.present) {
      map['exclude_keywords'] = Variable<String>(excludeKeywords.value);
    }
    if (mediaTypes.present) {
      map['media_types'] = Variable<String>(mediaTypes.value);
    }
    if (feedTypes.present) {
      map['feed_types'] = Variable<String>(feedTypes.value);
    }
    if (matchWholeWord.present) {
      map['match_whole_word'] = Variable<bool>(matchWholeWord.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FiltersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountId: $accountId, ')
          ..write('includeKeywords: $includeKeywords, ')
          ..write('excludeKeywords: $excludeKeywords, ')
          ..write('mediaTypes: $mediaTypes, ')
          ..write('feedTypes: $feedTypes, ')
          ..write('matchWholeWord: $matchWholeWord, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScrollPositionsTable extends ScrollPositions
    with TableInfo<$ScrollPositionsTable, ScrollPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScrollPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timelineIdMeta =
      const VerificationMeta('timelineId');
  @override
  late final GeneratedColumn<String> timelineId = GeneratedColumn<String>(
      'timeline_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastItemIdMeta =
      const VerificationMeta('lastItemId');
  @override
  late final GeneratedColumn<int> lastItemId = GeneratedColumn<int>(
      'last_item_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scrollOffsetMeta =
      const VerificationMeta('scrollOffset');
  @override
  late final GeneratedColumn<double> scrollOffset = GeneratedColumn<double>(
      'scroll_offset', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, timelineId, accountId, lastItemId, scrollOffset, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scroll_positions';
  @override
  VerificationContext validateIntegrity(Insertable<ScrollPosition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timeline_id')) {
      context.handle(
          _timelineIdMeta,
          timelineId.isAcceptableOrUnknown(
              data['timeline_id']!, _timelineIdMeta));
    } else if (isInserting) {
      context.missing(_timelineIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('last_item_id')) {
      context.handle(
          _lastItemIdMeta,
          lastItemId.isAcceptableOrUnknown(
              data['last_item_id']!, _lastItemIdMeta));
    }
    if (data.containsKey('scroll_offset')) {
      context.handle(
          _scrollOffsetMeta,
          scrollOffset.isAcceptableOrUnknown(
              data['scroll_offset']!, _scrollOffsetMeta));
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScrollPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScrollPosition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timelineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timeline_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id']),
      lastItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_item_id']),
      scrollOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scroll_offset'])!,
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!,
    );
  }

  @override
  $ScrollPositionsTable createAlias(String alias) {
    return $ScrollPositionsTable(attachedDatabase, alias);
  }
}

class ScrollPosition extends DataClass implements Insertable<ScrollPosition> {
  final int id;
  final String timelineId;
  final int? accountId;
  final int? lastItemId;
  final double scrollOffset;
  final DateTime savedAt;
  const ScrollPosition(
      {required this.id,
      required this.timelineId,
      this.accountId,
      this.lastItemId,
      required this.scrollOffset,
      required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timeline_id'] = Variable<String>(timelineId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || lastItemId != null) {
      map['last_item_id'] = Variable<int>(lastItemId);
    }
    map['scroll_offset'] = Variable<double>(scrollOffset);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  ScrollPositionsCompanion toCompanion(bool nullToAbsent) {
    return ScrollPositionsCompanion(
      id: Value(id),
      timelineId: Value(timelineId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      lastItemId: lastItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastItemId),
      scrollOffset: Value(scrollOffset),
      savedAt: Value(savedAt),
    );
  }

  factory ScrollPosition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScrollPosition(
      id: serializer.fromJson<int>(json['id']),
      timelineId: serializer.fromJson<String>(json['timelineId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      lastItemId: serializer.fromJson<int?>(json['lastItemId']),
      scrollOffset: serializer.fromJson<double>(json['scrollOffset']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timelineId': serializer.toJson<String>(timelineId),
      'accountId': serializer.toJson<int?>(accountId),
      'lastItemId': serializer.toJson<int?>(lastItemId),
      'scrollOffset': serializer.toJson<double>(scrollOffset),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  ScrollPosition copyWith(
          {int? id,
          String? timelineId,
          Value<int?> accountId = const Value.absent(),
          Value<int?> lastItemId = const Value.absent(),
          double? scrollOffset,
          DateTime? savedAt}) =>
      ScrollPosition(
        id: id ?? this.id,
        timelineId: timelineId ?? this.timelineId,
        accountId: accountId.present ? accountId.value : this.accountId,
        lastItemId: lastItemId.present ? lastItemId.value : this.lastItemId,
        scrollOffset: scrollOffset ?? this.scrollOffset,
        savedAt: savedAt ?? this.savedAt,
      );
  ScrollPosition copyWithCompanion(ScrollPositionsCompanion data) {
    return ScrollPosition(
      id: data.id.present ? data.id.value : this.id,
      timelineId:
          data.timelineId.present ? data.timelineId.value : this.timelineId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      lastItemId:
          data.lastItemId.present ? data.lastItemId.value : this.lastItemId,
      scrollOffset: data.scrollOffset.present
          ? data.scrollOffset.value
          : this.scrollOffset,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScrollPosition(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('accountId: $accountId, ')
          ..write('lastItemId: $lastItemId, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timelineId, accountId, lastItemId, scrollOffset, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScrollPosition &&
          other.id == this.id &&
          other.timelineId == this.timelineId &&
          other.accountId == this.accountId &&
          other.lastItemId == this.lastItemId &&
          other.scrollOffset == this.scrollOffset &&
          other.savedAt == this.savedAt);
}

class ScrollPositionsCompanion extends UpdateCompanion<ScrollPosition> {
  final Value<int> id;
  final Value<String> timelineId;
  final Value<int?> accountId;
  final Value<int?> lastItemId;
  final Value<double> scrollOffset;
  final Value<DateTime> savedAt;
  const ScrollPositionsCompanion({
    this.id = const Value.absent(),
    this.timelineId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.lastItemId = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  ScrollPositionsCompanion.insert({
    this.id = const Value.absent(),
    required String timelineId,
    this.accountId = const Value.absent(),
    this.lastItemId = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    required DateTime savedAt,
  })  : timelineId = Value(timelineId),
        savedAt = Value(savedAt);
  static Insertable<ScrollPosition> custom({
    Expression<int>? id,
    Expression<String>? timelineId,
    Expression<int>? accountId,
    Expression<int>? lastItemId,
    Expression<double>? scrollOffset,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timelineId != null) 'timeline_id': timelineId,
      if (accountId != null) 'account_id': accountId,
      if (lastItemId != null) 'last_item_id': lastItemId,
      if (scrollOffset != null) 'scroll_offset': scrollOffset,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  ScrollPositionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? timelineId,
      Value<int?>? accountId,
      Value<int?>? lastItemId,
      Value<double>? scrollOffset,
      Value<DateTime>? savedAt}) {
    return ScrollPositionsCompanion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      accountId: accountId ?? this.accountId,
      lastItemId: lastItemId ?? this.lastItemId,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timelineId.present) {
      map['timeline_id'] = Variable<String>(timelineId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (lastItemId.present) {
      map['last_item_id'] = Variable<int>(lastItemId.value);
    }
    if (scrollOffset.present) {
      map['scroll_offset'] = Variable<double>(scrollOffset.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScrollPositionsCompanion(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('accountId: $accountId, ')
          ..write('lastItemId: $lastItemId, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _themeModeIndexMeta =
      const VerificationMeta('themeModeIndex');
  @override
  late final GeneratedColumn<int> themeModeIndex = GeneratedColumn<int>(
      'theme_mode_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _fontSizeLevelMeta =
      const VerificationMeta('fontSizeLevel');
  @override
  late final GeneratedColumn<int> fontSizeLevel = GeneratedColumn<int>(
      'font_size_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _lineHeightLevelMeta =
      const VerificationMeta('lineHeightLevel');
  @override
  late final GeneratedColumn<int> lineHeightLevel = GeneratedColumn<int>(
      'line_height_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _maxContentWidthMeta =
      const VerificationMeta('maxContentWidth');
  @override
  late final GeneratedColumn<double> maxContentWidth = GeneratedColumn<double>(
      'max_content_width', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(680.0));
  static const VerificationMeta _bionicReadingMeta =
      const VerificationMeta('bionicReading');
  @override
  late final GeneratedColumn<bool> bionicReading = GeneratedColumn<bool>(
      'bionic_reading', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bionic_reading" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showAvatarsMeta =
      const VerificationMeta('showAvatars');
  @override
  late final GeneratedColumn<bool> showAvatars = GeneratedColumn<bool>(
      'show_avatars', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_avatars" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _avatarStyleMeta =
      const VerificationMeta('avatarStyle');
  @override
  late final GeneratedColumn<String> avatarStyle = GeneratedColumn<String>(
      'avatar_style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('rounded'));
  static const VerificationMeta _showFolderIconsMeta =
      const VerificationMeta('showFolderIcons');
  @override
  late final GeneratedColumn<bool> showFolderIcons = GeneratedColumn<bool>(
      'show_folder_icons', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_folder_icons" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _showThumbnailsMeta =
      const VerificationMeta('showThumbnails');
  @override
  late final GeneratedColumn<bool> showThumbnails = GeneratedColumn<bool>(
      'show_thumbnails', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_thumbnails" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _compactModeMeta =
      const VerificationMeta('compactMode');
  @override
  late final GeneratedColumn<bool> compactMode = GeneratedColumn<bool>(
      'compact_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("compact_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<String> sortOrder = GeneratedColumn<String>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('newest'));
  static const VerificationMeta _groupByFeedMeta =
      const VerificationMeta('groupByFeed');
  @override
  late final GeneratedColumn<bool> groupByFeed = GeneratedColumn<bool>(
      'group_by_feed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("group_by_feed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _markReadOnScrollMeta =
      const VerificationMeta('markReadOnScroll');
  @override
  late final GeneratedColumn<bool> markReadOnScroll = GeneratedColumn<bool>(
      'mark_read_on_scroll', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("mark_read_on_scroll" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _contentExpiryDaysMeta =
      const VerificationMeta('contentExpiryDays');
  @override
  late final GeneratedColumn<int> contentExpiryDays = GeneratedColumn<int>(
      'content_expiry_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cacheImagesMeta =
      const VerificationMeta('cacheImages');
  @override
  late final GeneratedColumn<bool> cacheImages = GeneratedColumn<bool>(
      'cache_images', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cache_images" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _maxCacheSizeMBMeta =
      const VerificationMeta('maxCacheSizeMB');
  @override
  late final GeneratedColumn<int> maxCacheSizeMB = GeneratedColumn<int>(
      'max_cache_size_m_b', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(500));
  static const VerificationMeta _autoRefreshIntervalMinutesMeta =
      const VerificationMeta('autoRefreshIntervalMinutes');
  @override
  late final GeneratedColumn<int> autoRefreshIntervalMinutes =
      GeneratedColumn<int>('auto_refresh_interval_minutes', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(30));
  static const VerificationMeta _playbackSpeedMeta =
      const VerificationMeta('playbackSpeed');
  @override
  late final GeneratedColumn<double> playbackSpeed = GeneratedColumn<double>(
      'playback_speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _skipForwardSecondsMeta =
      const VerificationMeta('skipForwardSeconds');
  @override
  late final GeneratedColumn<int> skipForwardSeconds = GeneratedColumn<int>(
      'skip_forward_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _skipBackwardSecondsMeta =
      const VerificationMeta('skipBackwardSeconds');
  @override
  late final GeneratedColumn<int> skipBackwardSeconds = GeneratedColumn<int>(
      'skip_backward_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        themeModeIndex,
        fontSizeLevel,
        lineHeightLevel,
        maxContentWidth,
        bionicReading,
        showAvatars,
        avatarStyle,
        showFolderIcons,
        showThumbnails,
        compactMode,
        sortOrder,
        groupByFeed,
        markReadOnScroll,
        contentExpiryDays,
        notificationsEnabled,
        cacheImages,
        maxCacheSizeMB,
        autoRefreshIntervalMinutes,
        playbackSpeed,
        skipForwardSeconds,
        skipBackwardSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode_index')) {
      context.handle(
          _themeModeIndexMeta,
          themeModeIndex.isAcceptableOrUnknown(
              data['theme_mode_index']!, _themeModeIndexMeta));
    }
    if (data.containsKey('font_size_level')) {
      context.handle(
          _fontSizeLevelMeta,
          fontSizeLevel.isAcceptableOrUnknown(
              data['font_size_level']!, _fontSizeLevelMeta));
    }
    if (data.containsKey('line_height_level')) {
      context.handle(
          _lineHeightLevelMeta,
          lineHeightLevel.isAcceptableOrUnknown(
              data['line_height_level']!, _lineHeightLevelMeta));
    }
    if (data.containsKey('max_content_width')) {
      context.handle(
          _maxContentWidthMeta,
          maxContentWidth.isAcceptableOrUnknown(
              data['max_content_width']!, _maxContentWidthMeta));
    }
    if (data.containsKey('bionic_reading')) {
      context.handle(
          _bionicReadingMeta,
          bionicReading.isAcceptableOrUnknown(
              data['bionic_reading']!, _bionicReadingMeta));
    }
    if (data.containsKey('show_avatars')) {
      context.handle(
          _showAvatarsMeta,
          showAvatars.isAcceptableOrUnknown(
              data['show_avatars']!, _showAvatarsMeta));
    }
    if (data.containsKey('avatar_style')) {
      context.handle(
          _avatarStyleMeta,
          avatarStyle.isAcceptableOrUnknown(
              data['avatar_style']!, _avatarStyleMeta));
    }
    if (data.containsKey('show_folder_icons')) {
      context.handle(
          _showFolderIconsMeta,
          showFolderIcons.isAcceptableOrUnknown(
              data['show_folder_icons']!, _showFolderIconsMeta));
    }
    if (data.containsKey('show_thumbnails')) {
      context.handle(
          _showThumbnailsMeta,
          showThumbnails.isAcceptableOrUnknown(
              data['show_thumbnails']!, _showThumbnailsMeta));
    }
    if (data.containsKey('compact_mode')) {
      context.handle(
          _compactModeMeta,
          compactMode.isAcceptableOrUnknown(
              data['compact_mode']!, _compactModeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('group_by_feed')) {
      context.handle(
          _groupByFeedMeta,
          groupByFeed.isAcceptableOrUnknown(
              data['group_by_feed']!, _groupByFeedMeta));
    }
    if (data.containsKey('mark_read_on_scroll')) {
      context.handle(
          _markReadOnScrollMeta,
          markReadOnScroll.isAcceptableOrUnknown(
              data['mark_read_on_scroll']!, _markReadOnScrollMeta));
    }
    if (data.containsKey('content_expiry_days')) {
      context.handle(
          _contentExpiryDaysMeta,
          contentExpiryDays.isAcceptableOrUnknown(
              data['content_expiry_days']!, _contentExpiryDaysMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('cache_images')) {
      context.handle(
          _cacheImagesMeta,
          cacheImages.isAcceptableOrUnknown(
              data['cache_images']!, _cacheImagesMeta));
    }
    if (data.containsKey('max_cache_size_m_b')) {
      context.handle(
          _maxCacheSizeMBMeta,
          maxCacheSizeMB.isAcceptableOrUnknown(
              data['max_cache_size_m_b']!, _maxCacheSizeMBMeta));
    }
    if (data.containsKey('auto_refresh_interval_minutes')) {
      context.handle(
          _autoRefreshIntervalMinutesMeta,
          autoRefreshIntervalMinutes.isAcceptableOrUnknown(
              data['auto_refresh_interval_minutes']!,
              _autoRefreshIntervalMinutesMeta));
    }
    if (data.containsKey('playback_speed')) {
      context.handle(
          _playbackSpeedMeta,
          playbackSpeed.isAcceptableOrUnknown(
              data['playback_speed']!, _playbackSpeedMeta));
    }
    if (data.containsKey('skip_forward_seconds')) {
      context.handle(
          _skipForwardSecondsMeta,
          skipForwardSeconds.isAcceptableOrUnknown(
              data['skip_forward_seconds']!, _skipForwardSecondsMeta));
    }
    if (data.containsKey('skip_backward_seconds')) {
      context.handle(
          _skipBackwardSecondsMeta,
          skipBackwardSeconds.isAcceptableOrUnknown(
              data['skip_backward_seconds']!, _skipBackwardSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      themeModeIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}theme_mode_index'])!,
      fontSizeLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}font_size_level'])!,
      lineHeightLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_height_level'])!,
      maxContentWidth: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}max_content_width'])!,
      bionicReading: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bionic_reading'])!,
      showAvatars: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_avatars'])!,
      avatarStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_style'])!,
      showFolderIcons: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_folder_icons'])!,
      showThumbnails: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_thumbnails'])!,
      compactMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}compact_mode'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sort_order'])!,
      groupByFeed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}group_by_feed'])!,
      markReadOnScroll: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}mark_read_on_scroll'])!,
      contentExpiryDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}content_expiry_days'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      cacheImages: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cache_images'])!,
      maxCacheSizeMB: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_cache_size_m_b'])!,
      autoRefreshIntervalMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}auto_refresh_interval_minutes'])!,
      playbackSpeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}playback_speed'])!,
      skipForwardSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}skip_forward_seconds'])!,
      skipBackwardSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}skip_backward_seconds'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final int id;
  final int themeModeIndex;
  final int fontSizeLevel;
  final int lineHeightLevel;
  final double maxContentWidth;
  final bool bionicReading;
  final bool showAvatars;
  final String avatarStyle;
  final bool showFolderIcons;
  final bool showThumbnails;
  final bool compactMode;
  final String sortOrder;
  final bool groupByFeed;
  final bool markReadOnScroll;
  final int contentExpiryDays;
  final bool notificationsEnabled;
  final bool cacheImages;
  final int maxCacheSizeMB;
  final int autoRefreshIntervalMinutes;
  final double playbackSpeed;
  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  const AppSettingsTableData(
      {required this.id,
      required this.themeModeIndex,
      required this.fontSizeLevel,
      required this.lineHeightLevel,
      required this.maxContentWidth,
      required this.bionicReading,
      required this.showAvatars,
      required this.avatarStyle,
      required this.showFolderIcons,
      required this.showThumbnails,
      required this.compactMode,
      required this.sortOrder,
      required this.groupByFeed,
      required this.markReadOnScroll,
      required this.contentExpiryDays,
      required this.notificationsEnabled,
      required this.cacheImages,
      required this.maxCacheSizeMB,
      required this.autoRefreshIntervalMinutes,
      required this.playbackSpeed,
      required this.skipForwardSeconds,
      required this.skipBackwardSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode_index'] = Variable<int>(themeModeIndex);
    map['font_size_level'] = Variable<int>(fontSizeLevel);
    map['line_height_level'] = Variable<int>(lineHeightLevel);
    map['max_content_width'] = Variable<double>(maxContentWidth);
    map['bionic_reading'] = Variable<bool>(bionicReading);
    map['show_avatars'] = Variable<bool>(showAvatars);
    map['avatar_style'] = Variable<String>(avatarStyle);
    map['show_folder_icons'] = Variable<bool>(showFolderIcons);
    map['show_thumbnails'] = Variable<bool>(showThumbnails);
    map['compact_mode'] = Variable<bool>(compactMode);
    map['sort_order'] = Variable<String>(sortOrder);
    map['group_by_feed'] = Variable<bool>(groupByFeed);
    map['mark_read_on_scroll'] = Variable<bool>(markReadOnScroll);
    map['content_expiry_days'] = Variable<int>(contentExpiryDays);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['cache_images'] = Variable<bool>(cacheImages);
    map['max_cache_size_m_b'] = Variable<int>(maxCacheSizeMB);
    map['auto_refresh_interval_minutes'] =
        Variable<int>(autoRefreshIntervalMinutes);
    map['playback_speed'] = Variable<double>(playbackSpeed);
    map['skip_forward_seconds'] = Variable<int>(skipForwardSeconds);
    map['skip_backward_seconds'] = Variable<int>(skipBackwardSeconds);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      themeModeIndex: Value(themeModeIndex),
      fontSizeLevel: Value(fontSizeLevel),
      lineHeightLevel: Value(lineHeightLevel),
      maxContentWidth: Value(maxContentWidth),
      bionicReading: Value(bionicReading),
      showAvatars: Value(showAvatars),
      avatarStyle: Value(avatarStyle),
      showFolderIcons: Value(showFolderIcons),
      showThumbnails: Value(showThumbnails),
      compactMode: Value(compactMode),
      sortOrder: Value(sortOrder),
      groupByFeed: Value(groupByFeed),
      markReadOnScroll: Value(markReadOnScroll),
      contentExpiryDays: Value(contentExpiryDays),
      notificationsEnabled: Value(notificationsEnabled),
      cacheImages: Value(cacheImages),
      maxCacheSizeMB: Value(maxCacheSizeMB),
      autoRefreshIntervalMinutes: Value(autoRefreshIntervalMinutes),
      playbackSpeed: Value(playbackSpeed),
      skipForwardSeconds: Value(skipForwardSeconds),
      skipBackwardSeconds: Value(skipBackwardSeconds),
    );
  }

  factory AppSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      themeModeIndex: serializer.fromJson<int>(json['themeModeIndex']),
      fontSizeLevel: serializer.fromJson<int>(json['fontSizeLevel']),
      lineHeightLevel: serializer.fromJson<int>(json['lineHeightLevel']),
      maxContentWidth: serializer.fromJson<double>(json['maxContentWidth']),
      bionicReading: serializer.fromJson<bool>(json['bionicReading']),
      showAvatars: serializer.fromJson<bool>(json['showAvatars']),
      avatarStyle: serializer.fromJson<String>(json['avatarStyle']),
      showFolderIcons: serializer.fromJson<bool>(json['showFolderIcons']),
      showThumbnails: serializer.fromJson<bool>(json['showThumbnails']),
      compactMode: serializer.fromJson<bool>(json['compactMode']),
      sortOrder: serializer.fromJson<String>(json['sortOrder']),
      groupByFeed: serializer.fromJson<bool>(json['groupByFeed']),
      markReadOnScroll: serializer.fromJson<bool>(json['markReadOnScroll']),
      contentExpiryDays: serializer.fromJson<int>(json['contentExpiryDays']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      cacheImages: serializer.fromJson<bool>(json['cacheImages']),
      maxCacheSizeMB: serializer.fromJson<int>(json['maxCacheSizeMB']),
      autoRefreshIntervalMinutes:
          serializer.fromJson<int>(json['autoRefreshIntervalMinutes']),
      playbackSpeed: serializer.fromJson<double>(json['playbackSpeed']),
      skipForwardSeconds: serializer.fromJson<int>(json['skipForwardSeconds']),
      skipBackwardSeconds:
          serializer.fromJson<int>(json['skipBackwardSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeModeIndex': serializer.toJson<int>(themeModeIndex),
      'fontSizeLevel': serializer.toJson<int>(fontSizeLevel),
      'lineHeightLevel': serializer.toJson<int>(lineHeightLevel),
      'maxContentWidth': serializer.toJson<double>(maxContentWidth),
      'bionicReading': serializer.toJson<bool>(bionicReading),
      'showAvatars': serializer.toJson<bool>(showAvatars),
      'avatarStyle': serializer.toJson<String>(avatarStyle),
      'showFolderIcons': serializer.toJson<bool>(showFolderIcons),
      'showThumbnails': serializer.toJson<bool>(showThumbnails),
      'compactMode': serializer.toJson<bool>(compactMode),
      'sortOrder': serializer.toJson<String>(sortOrder),
      'groupByFeed': serializer.toJson<bool>(groupByFeed),
      'markReadOnScroll': serializer.toJson<bool>(markReadOnScroll),
      'contentExpiryDays': serializer.toJson<int>(contentExpiryDays),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'cacheImages': serializer.toJson<bool>(cacheImages),
      'maxCacheSizeMB': serializer.toJson<int>(maxCacheSizeMB),
      'autoRefreshIntervalMinutes':
          serializer.toJson<int>(autoRefreshIntervalMinutes),
      'playbackSpeed': serializer.toJson<double>(playbackSpeed),
      'skipForwardSeconds': serializer.toJson<int>(skipForwardSeconds),
      'skipBackwardSeconds': serializer.toJson<int>(skipBackwardSeconds),
    };
  }

  AppSettingsTableData copyWith(
          {int? id,
          int? themeModeIndex,
          int? fontSizeLevel,
          int? lineHeightLevel,
          double? maxContentWidth,
          bool? bionicReading,
          bool? showAvatars,
          String? avatarStyle,
          bool? showFolderIcons,
          bool? showThumbnails,
          bool? compactMode,
          String? sortOrder,
          bool? groupByFeed,
          bool? markReadOnScroll,
          int? contentExpiryDays,
          bool? notificationsEnabled,
          bool? cacheImages,
          int? maxCacheSizeMB,
          int? autoRefreshIntervalMinutes,
          double? playbackSpeed,
          int? skipForwardSeconds,
          int? skipBackwardSeconds}) =>
      AppSettingsTableData(
        id: id ?? this.id,
        themeModeIndex: themeModeIndex ?? this.themeModeIndex,
        fontSizeLevel: fontSizeLevel ?? this.fontSizeLevel,
        lineHeightLevel: lineHeightLevel ?? this.lineHeightLevel,
        maxContentWidth: maxContentWidth ?? this.maxContentWidth,
        bionicReading: bionicReading ?? this.bionicReading,
        showAvatars: showAvatars ?? this.showAvatars,
        avatarStyle: avatarStyle ?? this.avatarStyle,
        showFolderIcons: showFolderIcons ?? this.showFolderIcons,
        showThumbnails: showThumbnails ?? this.showThumbnails,
        compactMode: compactMode ?? this.compactMode,
        sortOrder: sortOrder ?? this.sortOrder,
        groupByFeed: groupByFeed ?? this.groupByFeed,
        markReadOnScroll: markReadOnScroll ?? this.markReadOnScroll,
        contentExpiryDays: contentExpiryDays ?? this.contentExpiryDays,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        cacheImages: cacheImages ?? this.cacheImages,
        maxCacheSizeMB: maxCacheSizeMB ?? this.maxCacheSizeMB,
        autoRefreshIntervalMinutes:
            autoRefreshIntervalMinutes ?? this.autoRefreshIntervalMinutes,
        playbackSpeed: playbackSpeed ?? this.playbackSpeed,
        skipForwardSeconds: skipForwardSeconds ?? this.skipForwardSeconds,
        skipBackwardSeconds: skipBackwardSeconds ?? this.skipBackwardSeconds,
      );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      themeModeIndex: data.themeModeIndex.present
          ? data.themeModeIndex.value
          : this.themeModeIndex,
      fontSizeLevel: data.fontSizeLevel.present
          ? data.fontSizeLevel.value
          : this.fontSizeLevel,
      lineHeightLevel: data.lineHeightLevel.present
          ? data.lineHeightLevel.value
          : this.lineHeightLevel,
      maxContentWidth: data.maxContentWidth.present
          ? data.maxContentWidth.value
          : this.maxContentWidth,
      bionicReading: data.bionicReading.present
          ? data.bionicReading.value
          : this.bionicReading,
      showAvatars:
          data.showAvatars.present ? data.showAvatars.value : this.showAvatars,
      avatarStyle:
          data.avatarStyle.present ? data.avatarStyle.value : this.avatarStyle,
      showFolderIcons: data.showFolderIcons.present
          ? data.showFolderIcons.value
          : this.showFolderIcons,
      showThumbnails: data.showThumbnails.present
          ? data.showThumbnails.value
          : this.showThumbnails,
      compactMode:
          data.compactMode.present ? data.compactMode.value : this.compactMode,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      groupByFeed:
          data.groupByFeed.present ? data.groupByFeed.value : this.groupByFeed,
      markReadOnScroll: data.markReadOnScroll.present
          ? data.markReadOnScroll.value
          : this.markReadOnScroll,
      contentExpiryDays: data.contentExpiryDays.present
          ? data.contentExpiryDays.value
          : this.contentExpiryDays,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      cacheImages:
          data.cacheImages.present ? data.cacheImages.value : this.cacheImages,
      maxCacheSizeMB: data.maxCacheSizeMB.present
          ? data.maxCacheSizeMB.value
          : this.maxCacheSizeMB,
      autoRefreshIntervalMinutes: data.autoRefreshIntervalMinutes.present
          ? data.autoRefreshIntervalMinutes.value
          : this.autoRefreshIntervalMinutes,
      playbackSpeed: data.playbackSpeed.present
          ? data.playbackSpeed.value
          : this.playbackSpeed,
      skipForwardSeconds: data.skipForwardSeconds.present
          ? data.skipForwardSeconds.value
          : this.skipForwardSeconds,
      skipBackwardSeconds: data.skipBackwardSeconds.present
          ? data.skipBackwardSeconds.value
          : this.skipBackwardSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('themeModeIndex: $themeModeIndex, ')
          ..write('fontSizeLevel: $fontSizeLevel, ')
          ..write('lineHeightLevel: $lineHeightLevel, ')
          ..write('maxContentWidth: $maxContentWidth, ')
          ..write('bionicReading: $bionicReading, ')
          ..write('showAvatars: $showAvatars, ')
          ..write('avatarStyle: $avatarStyle, ')
          ..write('showFolderIcons: $showFolderIcons, ')
          ..write('showThumbnails: $showThumbnails, ')
          ..write('compactMode: $compactMode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('groupByFeed: $groupByFeed, ')
          ..write('markReadOnScroll: $markReadOnScroll, ')
          ..write('contentExpiryDays: $contentExpiryDays, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('cacheImages: $cacheImages, ')
          ..write('maxCacheSizeMB: $maxCacheSizeMB, ')
          ..write('autoRefreshIntervalMinutes: $autoRefreshIntervalMinutes, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('skipForwardSeconds: $skipForwardSeconds, ')
          ..write('skipBackwardSeconds: $skipBackwardSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        themeModeIndex,
        fontSizeLevel,
        lineHeightLevel,
        maxContentWidth,
        bionicReading,
        showAvatars,
        avatarStyle,
        showFolderIcons,
        showThumbnails,
        compactMode,
        sortOrder,
        groupByFeed,
        markReadOnScroll,
        contentExpiryDays,
        notificationsEnabled,
        cacheImages,
        maxCacheSizeMB,
        autoRefreshIntervalMinutes,
        playbackSpeed,
        skipForwardSeconds,
        skipBackwardSeconds
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.themeModeIndex == this.themeModeIndex &&
          other.fontSizeLevel == this.fontSizeLevel &&
          other.lineHeightLevel == this.lineHeightLevel &&
          other.maxContentWidth == this.maxContentWidth &&
          other.bionicReading == this.bionicReading &&
          other.showAvatars == this.showAvatars &&
          other.avatarStyle == this.avatarStyle &&
          other.showFolderIcons == this.showFolderIcons &&
          other.showThumbnails == this.showThumbnails &&
          other.compactMode == this.compactMode &&
          other.sortOrder == this.sortOrder &&
          other.groupByFeed == this.groupByFeed &&
          other.markReadOnScroll == this.markReadOnScroll &&
          other.contentExpiryDays == this.contentExpiryDays &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.cacheImages == this.cacheImages &&
          other.maxCacheSizeMB == this.maxCacheSizeMB &&
          other.autoRefreshIntervalMinutes == this.autoRefreshIntervalMinutes &&
          other.playbackSpeed == this.playbackSpeed &&
          other.skipForwardSeconds == this.skipForwardSeconds &&
          other.skipBackwardSeconds == this.skipBackwardSeconds);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<int> id;
  final Value<int> themeModeIndex;
  final Value<int> fontSizeLevel;
  final Value<int> lineHeightLevel;
  final Value<double> maxContentWidth;
  final Value<bool> bionicReading;
  final Value<bool> showAvatars;
  final Value<String> avatarStyle;
  final Value<bool> showFolderIcons;
  final Value<bool> showThumbnails;
  final Value<bool> compactMode;
  final Value<String> sortOrder;
  final Value<bool> groupByFeed;
  final Value<bool> markReadOnScroll;
  final Value<int> contentExpiryDays;
  final Value<bool> notificationsEnabled;
  final Value<bool> cacheImages;
  final Value<int> maxCacheSizeMB;
  final Value<int> autoRefreshIntervalMinutes;
  final Value<double> playbackSpeed;
  final Value<int> skipForwardSeconds;
  final Value<int> skipBackwardSeconds;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.themeModeIndex = const Value.absent(),
    this.fontSizeLevel = const Value.absent(),
    this.lineHeightLevel = const Value.absent(),
    this.maxContentWidth = const Value.absent(),
    this.bionicReading = const Value.absent(),
    this.showAvatars = const Value.absent(),
    this.avatarStyle = const Value.absent(),
    this.showFolderIcons = const Value.absent(),
    this.showThumbnails = const Value.absent(),
    this.compactMode = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.groupByFeed = const Value.absent(),
    this.markReadOnScroll = const Value.absent(),
    this.contentExpiryDays = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.cacheImages = const Value.absent(),
    this.maxCacheSizeMB = const Value.absent(),
    this.autoRefreshIntervalMinutes = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.skipForwardSeconds = const Value.absent(),
    this.skipBackwardSeconds = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themeModeIndex = const Value.absent(),
    this.fontSizeLevel = const Value.absent(),
    this.lineHeightLevel = const Value.absent(),
    this.maxContentWidth = const Value.absent(),
    this.bionicReading = const Value.absent(),
    this.showAvatars = const Value.absent(),
    this.avatarStyle = const Value.absent(),
    this.showFolderIcons = const Value.absent(),
    this.showThumbnails = const Value.absent(),
    this.compactMode = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.groupByFeed = const Value.absent(),
    this.markReadOnScroll = const Value.absent(),
    this.contentExpiryDays = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.cacheImages = const Value.absent(),
    this.maxCacheSizeMB = const Value.absent(),
    this.autoRefreshIntervalMinutes = const Value.absent(),
    this.playbackSpeed = const Value.absent(),
    this.skipForwardSeconds = const Value.absent(),
    this.skipBackwardSeconds = const Value.absent(),
  });
  static Insertable<AppSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? themeModeIndex,
    Expression<int>? fontSizeLevel,
    Expression<int>? lineHeightLevel,
    Expression<double>? maxContentWidth,
    Expression<bool>? bionicReading,
    Expression<bool>? showAvatars,
    Expression<String>? avatarStyle,
    Expression<bool>? showFolderIcons,
    Expression<bool>? showThumbnails,
    Expression<bool>? compactMode,
    Expression<String>? sortOrder,
    Expression<bool>? groupByFeed,
    Expression<bool>? markReadOnScroll,
    Expression<int>? contentExpiryDays,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? cacheImages,
    Expression<int>? maxCacheSizeMB,
    Expression<int>? autoRefreshIntervalMinutes,
    Expression<double>? playbackSpeed,
    Expression<int>? skipForwardSeconds,
    Expression<int>? skipBackwardSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeModeIndex != null) 'theme_mode_index': themeModeIndex,
      if (fontSizeLevel != null) 'font_size_level': fontSizeLevel,
      if (lineHeightLevel != null) 'line_height_level': lineHeightLevel,
      if (maxContentWidth != null) 'max_content_width': maxContentWidth,
      if (bionicReading != null) 'bionic_reading': bionicReading,
      if (showAvatars != null) 'show_avatars': showAvatars,
      if (avatarStyle != null) 'avatar_style': avatarStyle,
      if (showFolderIcons != null) 'show_folder_icons': showFolderIcons,
      if (showThumbnails != null) 'show_thumbnails': showThumbnails,
      if (compactMode != null) 'compact_mode': compactMode,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (groupByFeed != null) 'group_by_feed': groupByFeed,
      if (markReadOnScroll != null) 'mark_read_on_scroll': markReadOnScroll,
      if (contentExpiryDays != null) 'content_expiry_days': contentExpiryDays,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (cacheImages != null) 'cache_images': cacheImages,
      if (maxCacheSizeMB != null) 'max_cache_size_m_b': maxCacheSizeMB,
      if (autoRefreshIntervalMinutes != null)
        'auto_refresh_interval_minutes': autoRefreshIntervalMinutes,
      if (playbackSpeed != null) 'playback_speed': playbackSpeed,
      if (skipForwardSeconds != null)
        'skip_forward_seconds': skipForwardSeconds,
      if (skipBackwardSeconds != null)
        'skip_backward_seconds': skipBackwardSeconds,
    });
  }

  AppSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? themeModeIndex,
      Value<int>? fontSizeLevel,
      Value<int>? lineHeightLevel,
      Value<double>? maxContentWidth,
      Value<bool>? bionicReading,
      Value<bool>? showAvatars,
      Value<String>? avatarStyle,
      Value<bool>? showFolderIcons,
      Value<bool>? showThumbnails,
      Value<bool>? compactMode,
      Value<String>? sortOrder,
      Value<bool>? groupByFeed,
      Value<bool>? markReadOnScroll,
      Value<int>? contentExpiryDays,
      Value<bool>? notificationsEnabled,
      Value<bool>? cacheImages,
      Value<int>? maxCacheSizeMB,
      Value<int>? autoRefreshIntervalMinutes,
      Value<double>? playbackSpeed,
      Value<int>? skipForwardSeconds,
      Value<int>? skipBackwardSeconds}) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      fontSizeLevel: fontSizeLevel ?? this.fontSizeLevel,
      lineHeightLevel: lineHeightLevel ?? this.lineHeightLevel,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      bionicReading: bionicReading ?? this.bionicReading,
      showAvatars: showAvatars ?? this.showAvatars,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      showFolderIcons: showFolderIcons ?? this.showFolderIcons,
      showThumbnails: showThumbnails ?? this.showThumbnails,
      compactMode: compactMode ?? this.compactMode,
      sortOrder: sortOrder ?? this.sortOrder,
      groupByFeed: groupByFeed ?? this.groupByFeed,
      markReadOnScroll: markReadOnScroll ?? this.markReadOnScroll,
      contentExpiryDays: contentExpiryDays ?? this.contentExpiryDays,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      cacheImages: cacheImages ?? this.cacheImages,
      maxCacheSizeMB: maxCacheSizeMB ?? this.maxCacheSizeMB,
      autoRefreshIntervalMinutes:
          autoRefreshIntervalMinutes ?? this.autoRefreshIntervalMinutes,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      skipForwardSeconds: skipForwardSeconds ?? this.skipForwardSeconds,
      skipBackwardSeconds: skipBackwardSeconds ?? this.skipBackwardSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeModeIndex.present) {
      map['theme_mode_index'] = Variable<int>(themeModeIndex.value);
    }
    if (fontSizeLevel.present) {
      map['font_size_level'] = Variable<int>(fontSizeLevel.value);
    }
    if (lineHeightLevel.present) {
      map['line_height_level'] = Variable<int>(lineHeightLevel.value);
    }
    if (maxContentWidth.present) {
      map['max_content_width'] = Variable<double>(maxContentWidth.value);
    }
    if (bionicReading.present) {
      map['bionic_reading'] = Variable<bool>(bionicReading.value);
    }
    if (showAvatars.present) {
      map['show_avatars'] = Variable<bool>(showAvatars.value);
    }
    if (avatarStyle.present) {
      map['avatar_style'] = Variable<String>(avatarStyle.value);
    }
    if (showFolderIcons.present) {
      map['show_folder_icons'] = Variable<bool>(showFolderIcons.value);
    }
    if (showThumbnails.present) {
      map['show_thumbnails'] = Variable<bool>(showThumbnails.value);
    }
    if (compactMode.present) {
      map['compact_mode'] = Variable<bool>(compactMode.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<String>(sortOrder.value);
    }
    if (groupByFeed.present) {
      map['group_by_feed'] = Variable<bool>(groupByFeed.value);
    }
    if (markReadOnScroll.present) {
      map['mark_read_on_scroll'] = Variable<bool>(markReadOnScroll.value);
    }
    if (contentExpiryDays.present) {
      map['content_expiry_days'] = Variable<int>(contentExpiryDays.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (cacheImages.present) {
      map['cache_images'] = Variable<bool>(cacheImages.value);
    }
    if (maxCacheSizeMB.present) {
      map['max_cache_size_m_b'] = Variable<int>(maxCacheSizeMB.value);
    }
    if (autoRefreshIntervalMinutes.present) {
      map['auto_refresh_interval_minutes'] =
          Variable<int>(autoRefreshIntervalMinutes.value);
    }
    if (playbackSpeed.present) {
      map['playback_speed'] = Variable<double>(playbackSpeed.value);
    }
    if (skipForwardSeconds.present) {
      map['skip_forward_seconds'] = Variable<int>(skipForwardSeconds.value);
    }
    if (skipBackwardSeconds.present) {
      map['skip_backward_seconds'] = Variable<int>(skipBackwardSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themeModeIndex: $themeModeIndex, ')
          ..write('fontSizeLevel: $fontSizeLevel, ')
          ..write('lineHeightLevel: $lineHeightLevel, ')
          ..write('maxContentWidth: $maxContentWidth, ')
          ..write('bionicReading: $bionicReading, ')
          ..write('showAvatars: $showAvatars, ')
          ..write('avatarStyle: $avatarStyle, ')
          ..write('showFolderIcons: $showFolderIcons, ')
          ..write('showThumbnails: $showThumbnails, ')
          ..write('compactMode: $compactMode, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('groupByFeed: $groupByFeed, ')
          ..write('markReadOnScroll: $markReadOnScroll, ')
          ..write('contentExpiryDays: $contentExpiryDays, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('cacheImages: $cacheImages, ')
          ..write('maxCacheSizeMB: $maxCacheSizeMB, ')
          ..write('autoRefreshIntervalMinutes: $autoRefreshIntervalMinutes, ')
          ..write('playbackSpeed: $playbackSpeed, ')
          ..write('skipForwardSeconds: $skipForwardSeconds, ')
          ..write('skipBackwardSeconds: $skipBackwardSeconds')
          ..write(')'))
        .toString();
  }
}

class $SyncAccountsTable extends SyncAccounts
    with TableInfo<$SyncAccountsTable, SyncAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<int> serviceType = GeneratedColumn<int>(
      'service_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _serverUrlMeta =
      const VerificationMeta('serverUrl');
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
      'server_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serviceType,
        serverUrl,
        username,
        isActive,
        lastSyncAt,
        syncState,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<SyncAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('server_url')) {
      context.handle(_serverUrlMeta,
          serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_type'])!,
      serverUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_url']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncAccountsTable createAlias(String alias) {
    return $SyncAccountsTable(attachedDatabase, alias);
  }
}

class SyncAccount extends DataClass implements Insertable<SyncAccount> {
  final int id;

  /// Index into SyncServiceType enum.
  final int serviceType;

  /// Server URL for self-hosted services (FreshRSS, Reader).
  final String? serverUrl;

  /// Username or email for display.
  final String? username;

  /// Whether this is the currently active sync account.
  final bool isActive;

  /// Last successful sync timestamp.
  final DateTime? lastSyncAt;

  /// JSON-encoded sync state metadata.
  final String? syncState;
  final DateTime createdAt;
  const SyncAccount(
      {required this.id,
      required this.serviceType,
      this.serverUrl,
      this.username,
      required this.isActive,
      this.lastSyncAt,
      this.syncState,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_type'] = Variable<int>(serviceType);
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || syncState != null) {
      map['sync_state'] = Variable<String>(syncState);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncAccountsCompanion toCompanion(bool nullToAbsent) {
    return SyncAccountsCompanion(
      id: Value(id),
      serviceType: Value(serviceType),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      isActive: Value(isActive),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      syncState: syncState == null && nullToAbsent
          ? const Value.absent()
          : Value(syncState),
      createdAt: Value(createdAt),
    );
  }

  factory SyncAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncAccount(
      id: serializer.fromJson<int>(json['id']),
      serviceType: serializer.fromJson<int>(json['serviceType']),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      username: serializer.fromJson<String?>(json['username']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      syncState: serializer.fromJson<String?>(json['syncState']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceType': serializer.toJson<int>(serviceType),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'username': serializer.toJson<String?>(username),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'syncState': serializer.toJson<String?>(syncState),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncAccount copyWith(
          {int? id,
          int? serviceType,
          Value<String?> serverUrl = const Value.absent(),
          Value<String?> username = const Value.absent(),
          bool? isActive,
          Value<DateTime?> lastSyncAt = const Value.absent(),
          Value<String?> syncState = const Value.absent(),
          DateTime? createdAt}) =>
      SyncAccount(
        id: id ?? this.id,
        serviceType: serviceType ?? this.serviceType,
        serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
        username: username.present ? username.value : this.username,
        isActive: isActive ?? this.isActive,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
        syncState: syncState.present ? syncState.value : this.syncState,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncAccount copyWithCompanion(SyncAccountsCompanion data) {
    return SyncAccount(
      id: data.id.present ? data.id.value : this.id,
      serviceType:
          data.serviceType.present ? data.serviceType.value : this.serviceType,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      username: data.username.present ? data.username.value : this.username,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncAccount(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('username: $username, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serviceType, serverUrl, username,
      isActive, lastSyncAt, syncState, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncAccount &&
          other.id == this.id &&
          other.serviceType == this.serviceType &&
          other.serverUrl == this.serverUrl &&
          other.username == this.username &&
          other.isActive == this.isActive &&
          other.lastSyncAt == this.lastSyncAt &&
          other.syncState == this.syncState &&
          other.createdAt == this.createdAt);
}

class SyncAccountsCompanion extends UpdateCompanion<SyncAccount> {
  final Value<int> id;
  final Value<int> serviceType;
  final Value<String?> serverUrl;
  final Value<String?> username;
  final Value<bool> isActive;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> syncState;
  final Value<DateTime> createdAt;
  const SyncAccountsCompanion({
    this.id = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncAccountsCompanion.insert({
    this.id = const Value.absent(),
    required int serviceType,
    this.serverUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required DateTime createdAt,
  })  : serviceType = Value(serviceType),
        createdAt = Value(createdAt);
  static Insertable<SyncAccount> custom({
    Expression<int>? id,
    Expression<int>? serviceType,
    Expression<String>? serverUrl,
    Expression<String>? username,
    Expression<bool>? isActive,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? syncState,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceType != null) 'service_type': serviceType,
      if (serverUrl != null) 'server_url': serverUrl,
      if (username != null) 'username': username,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (syncState != null) 'sync_state': syncState,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncAccountsCompanion copyWith(
      {Value<int>? id,
      Value<int>? serviceType,
      Value<String?>? serverUrl,
      Value<String?>? username,
      Value<bool>? isActive,
      Value<DateTime?>? lastSyncAt,
      Value<String?>? syncState,
      Value<DateTime>? createdAt}) {
    return SyncAccountsCompanion(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      isActive: isActive ?? this.isActive,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<int>(serviceType.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncAccountsCompanion(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('username: $username, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('syncState: $syncState, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdsMeta =
      const VerificationMeta('itemIds');
  @override
  late final GeneratedColumn<String> itemIds = GeneratedColumn<String>(
      'item_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, action, itemIds, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('item_ids')) {
      context.handle(_itemIdsMeta,
          itemIds.isAcceptableOrUnknown(data['item_ids']!, _itemIdsMeta));
    } else if (isInserting) {
      context.missing(_itemIdsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      itemIds: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_ids'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;

  /// Reference to the sync account.
  final int accountId;

  /// Action type: markRead, markUnread, star, unstar, addFeed, removeFeed.
  final String action;

  /// JSON-encoded list of item IDs affected by this action.
  final String itemIds;
  final DateTime createdAt;

  /// Number of retry attempts.
  final int retryCount;
  const SyncQueueItem(
      {required this.id,
      required this.accountId,
      required this.action,
      required this.itemIds,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['action'] = Variable<String>(action);
    map['item_ids'] = Variable<String>(itemIds);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      action: Value(action),
      itemIds: Value(itemIds),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      action: serializer.fromJson<String>(json['action']),
      itemIds: serializer.fromJson<String>(json['itemIds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'action': serializer.toJson<String>(action),
      'itemIds': serializer.toJson<String>(itemIds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  SyncQueueItem copyWith(
          {int? id,
          int? accountId,
          String? action,
          String? itemIds,
          DateTime? createdAt,
          int? retryCount}) =>
      SyncQueueItem(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        action: action ?? this.action,
        itemIds: itemIds ?? this.itemIds,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      action: data.action.present ? data.action.value : this.action,
      itemIds: data.itemIds.present ? data.itemIds.value : this.itemIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('action: $action, ')
          ..write('itemIds: $itemIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, action, itemIds, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.action == this.action &&
          other.itemIds == this.itemIds &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<String> action;
  final Value<String> itemIds;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.action = const Value.absent(),
    this.itemIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required String action,
    required String itemIds,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
  })  : accountId = Value(accountId),
        action = Value(action),
        itemIds = Value(itemIds),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<String>? action,
    Expression<String>? itemIds,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (action != null) 'action': action,
      if (itemIds != null) 'item_ids': itemIds,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  SyncQueueItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? accountId,
      Value<String>? action,
      Value<String>? itemIds,
      Value<DateTime>? createdAt,
      Value<int>? retryCount}) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      action: action ?? this.action,
      itemIds: itemIds ?? this.itemIds,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (itemIds.present) {
      map['item_ids'] = Variable<String>(itemIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('action: $action, ')
          ..write('itemIds: $itemIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $RemoteIdMappingsTable extends RemoteIdMappings
    with TableInfo<$RemoteIdMappingsTable, RemoteIdMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteIdMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localTypeMeta =
      const VerificationMeta('localType');
  @override
  late final GeneratedColumn<String> localType = GeneratedColumn<String>(
      'local_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, localType, localId, remoteId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_id_mappings';
  @override
  VerificationContext validateIntegrity(Insertable<RemoteIdMapping> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('local_type')) {
      context.handle(_localTypeMeta,
          localType.isAcceptableOrUnknown(data['local_type']!, _localTypeMeta));
    } else if (isInserting) {
      context.missing(_localTypeMeta);
    }
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemoteIdMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteIdMapping(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      localType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_type'])!,
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id'])!,
    );
  }

  @override
  $RemoteIdMappingsTable createAlias(String alias) {
    return $RemoteIdMappingsTable(attachedDatabase, alias);
  }
}

class RemoteIdMapping extends DataClass implements Insertable<RemoteIdMapping> {
  final int id;

  /// Reference to the sync account.
  final int accountId;

  /// Type of entity: feed, article, folder.
  final String localType;

  /// Local database ID.
  final int localId;

  /// Remote service-specific ID.
  final String remoteId;
  const RemoteIdMapping(
      {required this.id,
      required this.accountId,
      required this.localType,
      required this.localId,
      required this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['local_type'] = Variable<String>(localType);
    map['local_id'] = Variable<int>(localId);
    map['remote_id'] = Variable<String>(remoteId);
    return map;
  }

  RemoteIdMappingsCompanion toCompanion(bool nullToAbsent) {
    return RemoteIdMappingsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      localType: Value(localType),
      localId: Value(localId),
      remoteId: Value(remoteId),
    );
  }

  factory RemoteIdMapping.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteIdMapping(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      localType: serializer.fromJson<String>(json['localType']),
      localId: serializer.fromJson<int>(json['localId']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'localType': serializer.toJson<String>(localType),
      'localId': serializer.toJson<int>(localId),
      'remoteId': serializer.toJson<String>(remoteId),
    };
  }

  RemoteIdMapping copyWith(
          {int? id,
          int? accountId,
          String? localType,
          int? localId,
          String? remoteId}) =>
      RemoteIdMapping(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        localType: localType ?? this.localType,
        localId: localId ?? this.localId,
        remoteId: remoteId ?? this.remoteId,
      );
  RemoteIdMapping copyWithCompanion(RemoteIdMappingsCompanion data) {
    return RemoteIdMapping(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      localType: data.localType.present ? data.localType.value : this.localType,
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteIdMapping(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('localType: $localType, ')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, localType, localId, remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteIdMapping &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.localType == this.localType &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId);
}

class RemoteIdMappingsCompanion extends UpdateCompanion<RemoteIdMapping> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<String> localType;
  final Value<int> localId;
  final Value<String> remoteId;
  const RemoteIdMappingsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.localType = const Value.absent(),
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  RemoteIdMappingsCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required String localType,
    required int localId,
    required String remoteId,
  })  : accountId = Value(accountId),
        localType = Value(localType),
        localId = Value(localId),
        remoteId = Value(remoteId);
  static Insertable<RemoteIdMapping> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<String>? localType,
    Expression<int>? localId,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (localType != null) 'local_type': localType,
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  RemoteIdMappingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? accountId,
      Value<String>? localType,
      Value<int>? localId,
      Value<String>? remoteId}) {
    return RemoteIdMappingsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      localType: localType ?? this.localType,
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (localType.present) {
      map['local_type'] = Variable<String>(localType.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteIdMappingsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('localType: $localType, ')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $FeedItemsTable feedItems = $FeedItemsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaggedItemsTable taggedItems = $TaggedItemsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $FiltersTable filters = $FiltersTable(this);
  late final $ScrollPositionsTable scrollPositions =
      $ScrollPositionsTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  late final $SyncAccountsTable syncAccounts = $SyncAccountsTable(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $RemoteIdMappingsTable remoteIdMappings =
      $RemoteIdMappingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        feeds,
        feedItems,
        tags,
        taggedItems,
        folders,
        filters,
        scrollPositions,
        appSettingsTable,
        syncAccounts,
        syncQueueItems,
        remoteIdMappings
      ];
}

typedef $$FeedsTableCreateCompanionBuilder = FeedsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required String feedUrl,
  Value<String?> siteUrl,
  Value<String?> iconUrl,
  Value<FeedType> type,
  Value<int?> folderId,
  Value<int> sortOrder,
  Value<DateTime?> lastFetched,
  Value<int?> fetchDurationMs,
  Value<ViewerType> defaultViewer,
  Value<bool> autoReaderView,
  Value<bool> notificationsEnabled,
  Value<int?> accountId,
  Value<int> unreadCount,
  Value<int> totalCount,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$FeedsTableUpdateCompanionBuilder = FeedsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<String> feedUrl,
  Value<String?> siteUrl,
  Value<String?> iconUrl,
  Value<FeedType> type,
  Value<int?> folderId,
  Value<int> sortOrder,
  Value<DateTime?> lastFetched,
  Value<int?> fetchDurationMs,
  Value<ViewerType> defaultViewer,
  Value<bool> autoReaderView,
  Value<bool> notificationsEnabled,
  Value<int?> accountId,
  Value<int> unreadCount,
  Value<int> totalCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FeedsTableFilterComposer extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedUrl => $composableBuilder(
      column: $table.feedUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteUrl => $composableBuilder(
      column: $table.siteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<FeedType, FeedType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetchDurationMs => $composableBuilder(
      column: $table.fetchDurationMs,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ViewerType, ViewerType, int>
      get defaultViewer => $composableBuilder(
          column: $table.defaultViewer,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get autoReaderView => $composableBuilder(
      column: $table.autoReaderView,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCount => $composableBuilder(
      column: $table.totalCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FeedsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedUrl => $composableBuilder(
      column: $table.feedUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteUrl => $composableBuilder(
      column: $table.siteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconUrl => $composableBuilder(
      column: $table.iconUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetchDurationMs => $composableBuilder(
      column: $table.fetchDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultViewer => $composableBuilder(
      column: $table.defaultViewer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoReaderView => $composableBuilder(
      column: $table.autoReaderView,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCount => $composableBuilder(
      column: $table.totalCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FeedType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
      column: $table.lastFetched, builder: (column) => column);

  GeneratedColumn<int> get fetchDurationMs => $composableBuilder(
      column: $table.fetchDurationMs, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ViewerType, int> get defaultViewer =>
      $composableBuilder(
          column: $table.defaultViewer, builder: (column) => column);

  GeneratedColumn<bool> get autoReaderView => $composableBuilder(
      column: $table.autoReaderView, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
      column: $table.totalCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FeedsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeedsTable,
    Feed,
    $$FeedsTableFilterComposer,
    $$FeedsTableOrderingComposer,
    $$FeedsTableAnnotationComposer,
    $$FeedsTableCreateCompanionBuilder,
    $$FeedsTableUpdateCompanionBuilder,
    (Feed, BaseReferences<_$AppDatabase, $FeedsTable, Feed>),
    Feed,
    PrefetchHooks Function()> {
  $$FeedsTableTableManager(_$AppDatabase db, $FeedsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> feedUrl = const Value.absent(),
            Value<String?> siteUrl = const Value.absent(),
            Value<String?> iconUrl = const Value.absent(),
            Value<FeedType> type = const Value.absent(),
            Value<int?> folderId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> lastFetched = const Value.absent(),
            Value<int?> fetchDurationMs = const Value.absent(),
            Value<ViewerType> defaultViewer = const Value.absent(),
            Value<bool> autoReaderView = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> totalCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FeedsCompanion(
            id: id,
            title: title,
            description: description,
            feedUrl: feedUrl,
            siteUrl: siteUrl,
            iconUrl: iconUrl,
            type: type,
            folderId: folderId,
            sortOrder: sortOrder,
            lastFetched: lastFetched,
            fetchDurationMs: fetchDurationMs,
            defaultViewer: defaultViewer,
            autoReaderView: autoReaderView,
            notificationsEnabled: notificationsEnabled,
            accountId: accountId,
            unreadCount: unreadCount,
            totalCount: totalCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required String feedUrl,
            Value<String?> siteUrl = const Value.absent(),
            Value<String?> iconUrl = const Value.absent(),
            Value<FeedType> type = const Value.absent(),
            Value<int?> folderId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> lastFetched = const Value.absent(),
            Value<int?> fetchDurationMs = const Value.absent(),
            Value<ViewerType> defaultViewer = const Value.absent(),
            Value<bool> autoReaderView = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<int> totalCount = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              FeedsCompanion.insert(
            id: id,
            title: title,
            description: description,
            feedUrl: feedUrl,
            siteUrl: siteUrl,
            iconUrl: iconUrl,
            type: type,
            folderId: folderId,
            sortOrder: sortOrder,
            lastFetched: lastFetched,
            fetchDurationMs: fetchDurationMs,
            defaultViewer: defaultViewer,
            autoReaderView: autoReaderView,
            notificationsEnabled: notificationsEnabled,
            accountId: accountId,
            unreadCount: unreadCount,
            totalCount: totalCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeedsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeedsTable,
    Feed,
    $$FeedsTableFilterComposer,
    $$FeedsTableOrderingComposer,
    $$FeedsTableAnnotationComposer,
    $$FeedsTableCreateCompanionBuilder,
    $$FeedsTableUpdateCompanionBuilder,
    (Feed, BaseReferences<_$AppDatabase, $FeedsTable, Feed>),
    Feed,
    PrefetchHooks Function()>;
typedef $$FeedItemsTableCreateCompanionBuilder = FeedItemsCompanion Function({
  Value<int> id,
  required int feedId,
  required String title,
  Value<String?> summary,
  Value<String?> content,
  required String url,
  Value<String?> imageUrl,
  Value<String?> imageUrls,
  Value<String?> audioUrl,
  Value<String?> videoUrl,
  Value<int?> audioDuration,
  Value<String?> author,
  required DateTime publishedAt,
  required DateTime fetchedAt,
  Value<ContentType> contentType,
  Value<bool> isRead,
  Value<bool> isStarred,
  Value<int?> readingTimeMinutes,
  Value<int?> accountId,
  Value<int?> wordCount,
  required DateTime createdAt,
});
typedef $$FeedItemsTableUpdateCompanionBuilder = FeedItemsCompanion Function({
  Value<int> id,
  Value<int> feedId,
  Value<String> title,
  Value<String?> summary,
  Value<String?> content,
  Value<String> url,
  Value<String?> imageUrl,
  Value<String?> imageUrls,
  Value<String?> audioUrl,
  Value<String?> videoUrl,
  Value<int?> audioDuration,
  Value<String?> author,
  Value<DateTime> publishedAt,
  Value<DateTime> fetchedAt,
  Value<ContentType> contentType,
  Value<bool> isRead,
  Value<bool> isStarred,
  Value<int?> readingTimeMinutes,
  Value<int?> accountId,
  Value<int?> wordCount,
  Value<DateTime> createdAt,
});

class $$FeedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get feedId => $composableBuilder(
      column: $table.feedId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get audioDuration => $composableBuilder(
      column: $table.audioDuration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ContentType, ContentType, int>
      get contentType => $composableBuilder(
          column: $table.contentType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStarred => $composableBuilder(
      column: $table.isStarred, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FeedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get feedId => $composableBuilder(
      column: $table.feedId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrls => $composableBuilder(
      column: $table.imageUrls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get audioDuration => $composableBuilder(
      column: $table.audioDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStarred => $composableBuilder(
      column: $table.isStarred, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FeedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedItemsTable> {
  $$FeedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get feedId =>
      $composableBuilder(column: $table.feedId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imageUrls =>
      $composableBuilder(column: $table.imageUrls, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<int> get audioDuration => $composableBuilder(
      column: $table.audioDuration, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContentType, int> get contentType =>
      $composableBuilder(
          column: $table.contentType, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<int> get readingTimeMinutes => $composableBuilder(
      column: $table.readingTimeMinutes, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeedItemsTable,
    FeedItem,
    $$FeedItemsTableFilterComposer,
    $$FeedItemsTableOrderingComposer,
    $$FeedItemsTableAnnotationComposer,
    $$FeedItemsTableCreateCompanionBuilder,
    $$FeedItemsTableUpdateCompanionBuilder,
    (FeedItem, BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItem>),
    FeedItem,
    PrefetchHooks Function()> {
  $$FeedItemsTableTableManager(_$AppDatabase db, $FeedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> feedId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> imageUrls = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<int?> audioDuration = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<DateTime> publishedAt = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<ContentType> contentType = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isStarred = const Value.absent(),
            Value<int?> readingTimeMinutes = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> wordCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FeedItemsCompanion(
            id: id,
            feedId: feedId,
            title: title,
            summary: summary,
            content: content,
            url: url,
            imageUrl: imageUrl,
            imageUrls: imageUrls,
            audioUrl: audioUrl,
            videoUrl: videoUrl,
            audioDuration: audioDuration,
            author: author,
            publishedAt: publishedAt,
            fetchedAt: fetchedAt,
            contentType: contentType,
            isRead: isRead,
            isStarred: isStarred,
            readingTimeMinutes: readingTimeMinutes,
            accountId: accountId,
            wordCount: wordCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int feedId,
            required String title,
            Value<String?> summary = const Value.absent(),
            Value<String?> content = const Value.absent(),
            required String url,
            Value<String?> imageUrl = const Value.absent(),
            Value<String?> imageUrls = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<int?> audioDuration = const Value.absent(),
            Value<String?> author = const Value.absent(),
            required DateTime publishedAt,
            required DateTime fetchedAt,
            Value<ContentType> contentType = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isStarred = const Value.absent(),
            Value<int?> readingTimeMinutes = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> wordCount = const Value.absent(),
            required DateTime createdAt,
          }) =>
              FeedItemsCompanion.insert(
            id: id,
            feedId: feedId,
            title: title,
            summary: summary,
            content: content,
            url: url,
            imageUrl: imageUrl,
            imageUrls: imageUrls,
            audioUrl: audioUrl,
            videoUrl: videoUrl,
            audioDuration: audioDuration,
            author: author,
            publishedAt: publishedAt,
            fetchedAt: fetchedAt,
            contentType: contentType,
            isRead: isRead,
            isStarred: isStarred,
            readingTimeMinutes: readingTimeMinutes,
            accountId: accountId,
            wordCount: wordCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeedItemsTable,
    FeedItem,
    $$FeedItemsTableFilterComposer,
    $$FeedItemsTableOrderingComposer,
    $$FeedItemsTableAnnotationComposer,
    $$FeedItemsTableCreateCompanionBuilder,
    $$FeedItemsTableUpdateCompanionBuilder,
    (FeedItem, BaseReferences<_$AppDatabase, $FeedItemsTable, FeedItem>),
    FeedItem,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> iconName,
  Value<int?> accountId,
  Value<bool> isBuiltIn,
  Value<bool> isShared,
  Value<String?> sharedFeedUrl,
  Value<int> itemCount,
  Value<int> sortOrder,
  required DateTime createdAt,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> iconName,
  Value<int?> accountId,
  Value<bool> isBuiltIn,
  Value<bool> isShared,
  Value<String?> sharedFeedUrl,
  Value<int> itemCount,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
      column: $table.isBuiltIn, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharedFeedUrl => $composableBuilder(
      column: $table.sharedFeedUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
      column: $table.isBuiltIn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isShared => $composableBuilder(
      column: $table.isShared, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharedFeedUrl => $composableBuilder(
      column: $table.sharedFeedUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);

  GeneratedColumn<String> get sharedFeedUrl => $composableBuilder(
      column: $table.sharedFeedUrl, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<bool> isBuiltIn = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> sharedFeedUrl = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            iconName: iconName,
            accountId: accountId,
            isBuiltIn: isBuiltIn,
            isShared: isShared,
            sharedFeedUrl: sharedFeedUrl,
            itemCount: itemCount,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> iconName = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<bool> isBuiltIn = const Value.absent(),
            Value<bool> isShared = const Value.absent(),
            Value<String?> sharedFeedUrl = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            iconName: iconName,
            accountId: accountId,
            isBuiltIn: isBuiltIn,
            isShared: isShared,
            sharedFeedUrl: sharedFeedUrl,
            itemCount: itemCount,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$TaggedItemsTableCreateCompanionBuilder = TaggedItemsCompanion
    Function({
  Value<int> id,
  required int tagId,
  required int itemId,
  Value<int?> accountId,
  required DateTime taggedAt,
});
typedef $$TaggedItemsTableUpdateCompanionBuilder = TaggedItemsCompanion
    Function({
  Value<int> id,
  Value<int> tagId,
  Value<int> itemId,
  Value<int?> accountId,
  Value<DateTime> taggedAt,
});

class $$TaggedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TaggedItemsTable> {
  $$TaggedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get taggedAt => $composableBuilder(
      column: $table.taggedAt, builder: (column) => ColumnFilters(column));
}

class $$TaggedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaggedItemsTable> {
  $$TaggedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get taggedAt => $composableBuilder(
      column: $table.taggedAt, builder: (column) => ColumnOrderings(column));
}

class $$TaggedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaggedItemsTable> {
  $$TaggedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get taggedAt =>
      $composableBuilder(column: $table.taggedAt, builder: (column) => column);
}

class $$TaggedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaggedItemsTable,
    TaggedItem,
    $$TaggedItemsTableFilterComposer,
    $$TaggedItemsTableOrderingComposer,
    $$TaggedItemsTableAnnotationComposer,
    $$TaggedItemsTableCreateCompanionBuilder,
    $$TaggedItemsTableUpdateCompanionBuilder,
    (TaggedItem, BaseReferences<_$AppDatabase, $TaggedItemsTable, TaggedItem>),
    TaggedItem,
    PrefetchHooks Function()> {
  $$TaggedItemsTableTableManager(_$AppDatabase db, $TaggedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaggedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaggedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaggedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<DateTime> taggedAt = const Value.absent(),
          }) =>
              TaggedItemsCompanion(
            id: id,
            tagId: tagId,
            itemId: itemId,
            accountId: accountId,
            taggedAt: taggedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int tagId,
            required int itemId,
            Value<int?> accountId = const Value.absent(),
            required DateTime taggedAt,
          }) =>
              TaggedItemsCompanion.insert(
            id: id,
            tagId: tagId,
            itemId: itemId,
            accountId: accountId,
            taggedAt: taggedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TaggedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaggedItemsTable,
    TaggedItem,
    $$TaggedItemsTableFilterComposer,
    $$TaggedItemsTableOrderingComposer,
    $$TaggedItemsTableAnnotationComposer,
    $$TaggedItemsTableCreateCompanionBuilder,
    $$TaggedItemsTableUpdateCompanionBuilder,
    (TaggedItem, BaseReferences<_$AppDatabase, $TaggedItemsTable, TaggedItem>),
    TaggedItem,
    PrefetchHooks Function()>;
typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> iconName,
  Value<int?> accountId,
  Value<int> sortOrder,
  Value<bool> isExpanded,
  Value<int> unreadCount,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> iconName,
  Value<int?> accountId,
  Value<int> sortOrder,
  Value<bool> isExpanded,
  Value<int> unreadCount,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExpanded => $composableBuilder(
      column: $table.isExpanded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExpanded => $composableBuilder(
      column: $table.isExpanded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isExpanded => $composableBuilder(
      column: $table.isExpanded, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
    Folder,
    PrefetchHooks Function()> {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isExpanded = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FoldersCompanion(
            id: id,
            name: name,
            iconName: iconName,
            accountId: accountId,
            sortOrder: sortOrder,
            isExpanded: isExpanded,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> iconName = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isExpanded = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              FoldersCompanion.insert(
            id: id,
            name: name,
            iconName: iconName,
            accountId: accountId,
            sortOrder: sortOrder,
            isExpanded: isExpanded,
            unreadCount: unreadCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
    Folder,
    PrefetchHooks Function()>;
typedef $$FiltersTableCreateCompanionBuilder = FiltersCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> accountId,
  Value<String> includeKeywords,
  Value<String> excludeKeywords,
  Value<String> mediaTypes,
  Value<String> feedTypes,
  Value<bool> matchWholeWord,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$FiltersTableUpdateCompanionBuilder = FiltersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> accountId,
  Value<String> includeKeywords,
  Value<String> excludeKeywords,
  Value<String> mediaTypes,
  Value<String> feedTypes,
  Value<bool> matchWholeWord,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$FiltersTableFilterComposer
    extends Composer<_$AppDatabase, $FiltersTable> {
  $$FiltersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get includeKeywords => $composableBuilder(
      column: $table.includeKeywords,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get excludeKeywords => $composableBuilder(
      column: $table.excludeKeywords,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaTypes => $composableBuilder(
      column: $table.mediaTypes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedTypes => $composableBuilder(
      column: $table.feedTypes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get matchWholeWord => $composableBuilder(
      column: $table.matchWholeWord,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FiltersTableOrderingComposer
    extends Composer<_$AppDatabase, $FiltersTable> {
  $$FiltersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get includeKeywords => $composableBuilder(
      column: $table.includeKeywords,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excludeKeywords => $composableBuilder(
      column: $table.excludeKeywords,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaTypes => $composableBuilder(
      column: $table.mediaTypes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedTypes => $composableBuilder(
      column: $table.feedTypes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get matchWholeWord => $composableBuilder(
      column: $table.matchWholeWord,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FiltersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FiltersTable> {
  $$FiltersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get includeKeywords => $composableBuilder(
      column: $table.includeKeywords, builder: (column) => column);

  GeneratedColumn<String> get excludeKeywords => $composableBuilder(
      column: $table.excludeKeywords, builder: (column) => column);

  GeneratedColumn<String> get mediaTypes => $composableBuilder(
      column: $table.mediaTypes, builder: (column) => column);

  GeneratedColumn<String> get feedTypes =>
      $composableBuilder(column: $table.feedTypes, builder: (column) => column);

  GeneratedColumn<bool> get matchWholeWord => $composableBuilder(
      column: $table.matchWholeWord, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FiltersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FiltersTable,
    Filter,
    $$FiltersTableFilterComposer,
    $$FiltersTableOrderingComposer,
    $$FiltersTableAnnotationComposer,
    $$FiltersTableCreateCompanionBuilder,
    $$FiltersTableUpdateCompanionBuilder,
    (Filter, BaseReferences<_$AppDatabase, $FiltersTable, Filter>),
    Filter,
    PrefetchHooks Function()> {
  $$FiltersTableTableManager(_$AppDatabase db, $FiltersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FiltersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FiltersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FiltersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<String> includeKeywords = const Value.absent(),
            Value<String> excludeKeywords = const Value.absent(),
            Value<String> mediaTypes = const Value.absent(),
            Value<String> feedTypes = const Value.absent(),
            Value<bool> matchWholeWord = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              FiltersCompanion(
            id: id,
            name: name,
            accountId: accountId,
            includeKeywords: includeKeywords,
            excludeKeywords: excludeKeywords,
            mediaTypes: mediaTypes,
            feedTypes: feedTypes,
            matchWholeWord: matchWholeWord,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int?> accountId = const Value.absent(),
            Value<String> includeKeywords = const Value.absent(),
            Value<String> excludeKeywords = const Value.absent(),
            Value<String> mediaTypes = const Value.absent(),
            Value<String> feedTypes = const Value.absent(),
            Value<bool> matchWholeWord = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              FiltersCompanion.insert(
            id: id,
            name: name,
            accountId: accountId,
            includeKeywords: includeKeywords,
            excludeKeywords: excludeKeywords,
            mediaTypes: mediaTypes,
            feedTypes: feedTypes,
            matchWholeWord: matchWholeWord,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FiltersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FiltersTable,
    Filter,
    $$FiltersTableFilterComposer,
    $$FiltersTableOrderingComposer,
    $$FiltersTableAnnotationComposer,
    $$FiltersTableCreateCompanionBuilder,
    $$FiltersTableUpdateCompanionBuilder,
    (Filter, BaseReferences<_$AppDatabase, $FiltersTable, Filter>),
    Filter,
    PrefetchHooks Function()>;
typedef $$ScrollPositionsTableCreateCompanionBuilder = ScrollPositionsCompanion
    Function({
  Value<int> id,
  required String timelineId,
  Value<int?> accountId,
  Value<int?> lastItemId,
  Value<double> scrollOffset,
  required DateTime savedAt,
});
typedef $$ScrollPositionsTableUpdateCompanionBuilder = ScrollPositionsCompanion
    Function({
  Value<int> id,
  Value<String> timelineId,
  Value<int?> accountId,
  Value<int?> lastItemId,
  Value<double> scrollOffset,
  Value<DateTime> savedAt,
});

class $$ScrollPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $ScrollPositionsTable> {
  $$ScrollPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timelineId => $composableBuilder(
      column: $table.timelineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastItemId => $composableBuilder(
      column: $table.lastItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));
}

class $$ScrollPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScrollPositionsTable> {
  $$ScrollPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timelineId => $composableBuilder(
      column: $table.timelineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastItemId => $composableBuilder(
      column: $table.lastItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));
}

class $$ScrollPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScrollPositionsTable> {
  $$ScrollPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timelineId => $composableBuilder(
      column: $table.timelineId, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get lastItemId => $composableBuilder(
      column: $table.lastItemId, builder: (column) => column);

  GeneratedColumn<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$ScrollPositionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScrollPositionsTable,
    ScrollPosition,
    $$ScrollPositionsTableFilterComposer,
    $$ScrollPositionsTableOrderingComposer,
    $$ScrollPositionsTableAnnotationComposer,
    $$ScrollPositionsTableCreateCompanionBuilder,
    $$ScrollPositionsTableUpdateCompanionBuilder,
    (
      ScrollPosition,
      BaseReferences<_$AppDatabase, $ScrollPositionsTable, ScrollPosition>
    ),
    ScrollPosition,
    PrefetchHooks Function()> {
  $$ScrollPositionsTableTableManager(
      _$AppDatabase db, $ScrollPositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScrollPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScrollPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScrollPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> timelineId = const Value.absent(),
            Value<int?> accountId = const Value.absent(),
            Value<int?> lastItemId = const Value.absent(),
            Value<double> scrollOffset = const Value.absent(),
            Value<DateTime> savedAt = const Value.absent(),
          }) =>
              ScrollPositionsCompanion(
            id: id,
            timelineId: timelineId,
            accountId: accountId,
            lastItemId: lastItemId,
            scrollOffset: scrollOffset,
            savedAt: savedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String timelineId,
            Value<int?> accountId = const Value.absent(),
            Value<int?> lastItemId = const Value.absent(),
            Value<double> scrollOffset = const Value.absent(),
            required DateTime savedAt,
          }) =>
              ScrollPositionsCompanion.insert(
            id: id,
            timelineId: timelineId,
            accountId: accountId,
            lastItemId: lastItemId,
            scrollOffset: scrollOffset,
            savedAt: savedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScrollPositionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScrollPositionsTable,
    ScrollPosition,
    $$ScrollPositionsTableFilterComposer,
    $$ScrollPositionsTableOrderingComposer,
    $$ScrollPositionsTableAnnotationComposer,
    $$ScrollPositionsTableCreateCompanionBuilder,
    $$ScrollPositionsTableUpdateCompanionBuilder,
    (
      ScrollPosition,
      BaseReferences<_$AppDatabase, $ScrollPositionsTable, ScrollPosition>
    ),
    ScrollPosition,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableTableCreateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<int> id,
  Value<int> themeModeIndex,
  Value<int> fontSizeLevel,
  Value<int> lineHeightLevel,
  Value<double> maxContentWidth,
  Value<bool> bionicReading,
  Value<bool> showAvatars,
  Value<String> avatarStyle,
  Value<bool> showFolderIcons,
  Value<bool> showThumbnails,
  Value<bool> compactMode,
  Value<String> sortOrder,
  Value<bool> groupByFeed,
  Value<bool> markReadOnScroll,
  Value<int> contentExpiryDays,
  Value<bool> notificationsEnabled,
  Value<bool> cacheImages,
  Value<int> maxCacheSizeMB,
  Value<int> autoRefreshIntervalMinutes,
  Value<double> playbackSpeed,
  Value<int> skipForwardSeconds,
  Value<int> skipBackwardSeconds,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<int> id,
  Value<int> themeModeIndex,
  Value<int> fontSizeLevel,
  Value<int> lineHeightLevel,
  Value<double> maxContentWidth,
  Value<bool> bionicReading,
  Value<bool> showAvatars,
  Value<String> avatarStyle,
  Value<bool> showFolderIcons,
  Value<bool> showThumbnails,
  Value<bool> compactMode,
  Value<String> sortOrder,
  Value<bool> groupByFeed,
  Value<bool> markReadOnScroll,
  Value<int> contentExpiryDays,
  Value<bool> notificationsEnabled,
  Value<bool> cacheImages,
  Value<int> maxCacheSizeMB,
  Value<int> autoRefreshIntervalMinutes,
  Value<double> playbackSpeed,
  Value<int> skipForwardSeconds,
  Value<int> skipBackwardSeconds,
});

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get themeModeIndex => $composableBuilder(
      column: $table.themeModeIndex,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fontSizeLevel => $composableBuilder(
      column: $table.fontSizeLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineHeightLevel => $composableBuilder(
      column: $table.lineHeightLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxContentWidth => $composableBuilder(
      column: $table.maxContentWidth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bionicReading => $composableBuilder(
      column: $table.bionicReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showAvatars => $composableBuilder(
      column: $table.showAvatars, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarStyle => $composableBuilder(
      column: $table.avatarStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showFolderIcons => $composableBuilder(
      column: $table.showFolderIcons,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showThumbnails => $composableBuilder(
      column: $table.showThumbnails,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get compactMode => $composableBuilder(
      column: $table.compactMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get groupByFeed => $composableBuilder(
      column: $table.groupByFeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get markReadOnScroll => $composableBuilder(
      column: $table.markReadOnScroll,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get contentExpiryDays => $composableBuilder(
      column: $table.contentExpiryDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cacheImages => $composableBuilder(
      column: $table.cacheImages, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxCacheSizeMB => $composableBuilder(
      column: $table.maxCacheSizeMB,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoRefreshIntervalMinutes => $composableBuilder(
      column: $table.autoRefreshIntervalMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skipForwardSeconds => $composableBuilder(
      column: $table.skipForwardSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skipBackwardSeconds => $composableBuilder(
      column: $table.skipBackwardSeconds,
      builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get themeModeIndex => $composableBuilder(
      column: $table.themeModeIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fontSizeLevel => $composableBuilder(
      column: $table.fontSizeLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineHeightLevel => $composableBuilder(
      column: $table.lineHeightLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxContentWidth => $composableBuilder(
      column: $table.maxContentWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bionicReading => $composableBuilder(
      column: $table.bionicReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showAvatars => $composableBuilder(
      column: $table.showAvatars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarStyle => $composableBuilder(
      column: $table.avatarStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showFolderIcons => $composableBuilder(
      column: $table.showFolderIcons,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showThumbnails => $composableBuilder(
      column: $table.showThumbnails,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get compactMode => $composableBuilder(
      column: $table.compactMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get groupByFeed => $composableBuilder(
      column: $table.groupByFeed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get markReadOnScroll => $composableBuilder(
      column: $table.markReadOnScroll,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get contentExpiryDays => $composableBuilder(
      column: $table.contentExpiryDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cacheImages => $composableBuilder(
      column: $table.cacheImages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxCacheSizeMB => $composableBuilder(
      column: $table.maxCacheSizeMB,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoRefreshIntervalMinutes => $composableBuilder(
      column: $table.autoRefreshIntervalMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skipForwardSeconds => $composableBuilder(
      column: $table.skipForwardSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skipBackwardSeconds => $composableBuilder(
      column: $table.skipBackwardSeconds,
      builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get themeModeIndex => $composableBuilder(
      column: $table.themeModeIndex, builder: (column) => column);

  GeneratedColumn<int> get fontSizeLevel => $composableBuilder(
      column: $table.fontSizeLevel, builder: (column) => column);

  GeneratedColumn<int> get lineHeightLevel => $composableBuilder(
      column: $table.lineHeightLevel, builder: (column) => column);

  GeneratedColumn<double> get maxContentWidth => $composableBuilder(
      column: $table.maxContentWidth, builder: (column) => column);

  GeneratedColumn<bool> get bionicReading => $composableBuilder(
      column: $table.bionicReading, builder: (column) => column);

  GeneratedColumn<bool> get showAvatars => $composableBuilder(
      column: $table.showAvatars, builder: (column) => column);

  GeneratedColumn<String> get avatarStyle => $composableBuilder(
      column: $table.avatarStyle, builder: (column) => column);

  GeneratedColumn<bool> get showFolderIcons => $composableBuilder(
      column: $table.showFolderIcons, builder: (column) => column);

  GeneratedColumn<bool> get showThumbnails => $composableBuilder(
      column: $table.showThumbnails, builder: (column) => column);

  GeneratedColumn<bool> get compactMode => $composableBuilder(
      column: $table.compactMode, builder: (column) => column);

  GeneratedColumn<String> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get groupByFeed => $composableBuilder(
      column: $table.groupByFeed, builder: (column) => column);

  GeneratedColumn<bool> get markReadOnScroll => $composableBuilder(
      column: $table.markReadOnScroll, builder: (column) => column);

  GeneratedColumn<int> get contentExpiryDays => $composableBuilder(
      column: $table.contentExpiryDays, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get cacheImages => $composableBuilder(
      column: $table.cacheImages, builder: (column) => column);

  GeneratedColumn<int> get maxCacheSizeMB => $composableBuilder(
      column: $table.maxCacheSizeMB, builder: (column) => column);

  GeneratedColumn<int> get autoRefreshIntervalMinutes => $composableBuilder(
      column: $table.autoRefreshIntervalMinutes, builder: (column) => column);

  GeneratedColumn<double> get playbackSpeed => $composableBuilder(
      column: $table.playbackSpeed, builder: (column) => column);

  GeneratedColumn<int> get skipForwardSeconds => $composableBuilder(
      column: $table.skipForwardSeconds, builder: (column) => column);

  GeneratedColumn<int> get skipBackwardSeconds => $composableBuilder(
      column: $table.skipBackwardSeconds, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableTableManager(
      _$AppDatabase db, $AppSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> themeModeIndex = const Value.absent(),
            Value<int> fontSizeLevel = const Value.absent(),
            Value<int> lineHeightLevel = const Value.absent(),
            Value<double> maxContentWidth = const Value.absent(),
            Value<bool> bionicReading = const Value.absent(),
            Value<bool> showAvatars = const Value.absent(),
            Value<String> avatarStyle = const Value.absent(),
            Value<bool> showFolderIcons = const Value.absent(),
            Value<bool> showThumbnails = const Value.absent(),
            Value<bool> compactMode = const Value.absent(),
            Value<String> sortOrder = const Value.absent(),
            Value<bool> groupByFeed = const Value.absent(),
            Value<bool> markReadOnScroll = const Value.absent(),
            Value<int> contentExpiryDays = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<bool> cacheImages = const Value.absent(),
            Value<int> maxCacheSizeMB = const Value.absent(),
            Value<int> autoRefreshIntervalMinutes = const Value.absent(),
            Value<double> playbackSpeed = const Value.absent(),
            Value<int> skipForwardSeconds = const Value.absent(),
            Value<int> skipBackwardSeconds = const Value.absent(),
          }) =>
              AppSettingsTableCompanion(
            id: id,
            themeModeIndex: themeModeIndex,
            fontSizeLevel: fontSizeLevel,
            lineHeightLevel: lineHeightLevel,
            maxContentWidth: maxContentWidth,
            bionicReading: bionicReading,
            showAvatars: showAvatars,
            avatarStyle: avatarStyle,
            showFolderIcons: showFolderIcons,
            showThumbnails: showThumbnails,
            compactMode: compactMode,
            sortOrder: sortOrder,
            groupByFeed: groupByFeed,
            markReadOnScroll: markReadOnScroll,
            contentExpiryDays: contentExpiryDays,
            notificationsEnabled: notificationsEnabled,
            cacheImages: cacheImages,
            maxCacheSizeMB: maxCacheSizeMB,
            autoRefreshIntervalMinutes: autoRefreshIntervalMinutes,
            playbackSpeed: playbackSpeed,
            skipForwardSeconds: skipForwardSeconds,
            skipBackwardSeconds: skipBackwardSeconds,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> themeModeIndex = const Value.absent(),
            Value<int> fontSizeLevel = const Value.absent(),
            Value<int> lineHeightLevel = const Value.absent(),
            Value<double> maxContentWidth = const Value.absent(),
            Value<bool> bionicReading = const Value.absent(),
            Value<bool> showAvatars = const Value.absent(),
            Value<String> avatarStyle = const Value.absent(),
            Value<bool> showFolderIcons = const Value.absent(),
            Value<bool> showThumbnails = const Value.absent(),
            Value<bool> compactMode = const Value.absent(),
            Value<String> sortOrder = const Value.absent(),
            Value<bool> groupByFeed = const Value.absent(),
            Value<bool> markReadOnScroll = const Value.absent(),
            Value<int> contentExpiryDays = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<bool> cacheImages = const Value.absent(),
            Value<int> maxCacheSizeMB = const Value.absent(),
            Value<int> autoRefreshIntervalMinutes = const Value.absent(),
            Value<double> playbackSpeed = const Value.absent(),
            Value<int> skipForwardSeconds = const Value.absent(),
            Value<int> skipBackwardSeconds = const Value.absent(),
          }) =>
              AppSettingsTableCompanion.insert(
            id: id,
            themeModeIndex: themeModeIndex,
            fontSizeLevel: fontSizeLevel,
            lineHeightLevel: lineHeightLevel,
            maxContentWidth: maxContentWidth,
            bionicReading: bionicReading,
            showAvatars: showAvatars,
            avatarStyle: avatarStyle,
            showFolderIcons: showFolderIcons,
            showThumbnails: showThumbnails,
            compactMode: compactMode,
            sortOrder: sortOrder,
            groupByFeed: groupByFeed,
            markReadOnScroll: markReadOnScroll,
            contentExpiryDays: contentExpiryDays,
            notificationsEnabled: notificationsEnabled,
            cacheImages: cacheImages,
            maxCacheSizeMB: maxCacheSizeMB,
            autoRefreshIntervalMinutes: autoRefreshIntervalMinutes,
            playbackSpeed: playbackSpeed,
            skipForwardSeconds: skipForwardSeconds,
            skipBackwardSeconds: skipBackwardSeconds,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSettingsTableData,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSettingsTableData,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable,
          AppSettingsTableData>
    ),
    AppSettingsTableData,
    PrefetchHooks Function()>;
typedef $$SyncAccountsTableCreateCompanionBuilder = SyncAccountsCompanion
    Function({
  Value<int> id,
  required int serviceType,
  Value<String?> serverUrl,
  Value<String?> username,
  Value<bool> isActive,
  Value<DateTime?> lastSyncAt,
  Value<String?> syncState,
  required DateTime createdAt,
});
typedef $$SyncAccountsTableUpdateCompanionBuilder = SyncAccountsCompanion
    Function({
  Value<int> id,
  Value<int> serviceType,
  Value<String?> serverUrl,
  Value<String?> username,
  Value<bool> isActive,
  Value<DateTime?> lastSyncAt,
  Value<String?> syncState,
  Value<DateTime> createdAt,
});

class $$SyncAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverUrl => $composableBuilder(
      column: $table.serverUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncAccountsTable> {
  $$SyncAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncAccountsTable,
    SyncAccount,
    $$SyncAccountsTableFilterComposer,
    $$SyncAccountsTableOrderingComposer,
    $$SyncAccountsTableAnnotationComposer,
    $$SyncAccountsTableCreateCompanionBuilder,
    $$SyncAccountsTableUpdateCompanionBuilder,
    (
      SyncAccount,
      BaseReferences<_$AppDatabase, $SyncAccountsTable, SyncAccount>
    ),
    SyncAccount,
    PrefetchHooks Function()> {
  $$SyncAccountsTableTableManager(_$AppDatabase db, $SyncAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> serviceType = const Value.absent(),
            Value<String?> serverUrl = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> syncState = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncAccountsCompanion(
            id: id,
            serviceType: serviceType,
            serverUrl: serverUrl,
            username: username,
            isActive: isActive,
            lastSyncAt: lastSyncAt,
            syncState: syncState,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int serviceType,
            Value<String?> serverUrl = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<String?> syncState = const Value.absent(),
            required DateTime createdAt,
          }) =>
              SyncAccountsCompanion.insert(
            id: id,
            serviceType: serviceType,
            serverUrl: serverUrl,
            username: username,
            isActive: isActive,
            lastSyncAt: lastSyncAt,
            syncState: syncState,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncAccountsTable,
    SyncAccount,
    $$SyncAccountsTableFilterComposer,
    $$SyncAccountsTableOrderingComposer,
    $$SyncAccountsTableAnnotationComposer,
    $$SyncAccountsTableCreateCompanionBuilder,
    $$SyncAccountsTableUpdateCompanionBuilder,
    (
      SyncAccount,
      BaseReferences<_$AppDatabase, $SyncAccountsTable, SyncAccount>
    ),
    SyncAccount,
    PrefetchHooks Function()>;
typedef $$SyncQueueItemsTableCreateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  Value<int> id,
  required int accountId,
  required String action,
  required String itemIds,
  required DateTime createdAt,
  Value<int> retryCount,
});
typedef $$SyncQueueItemsTableUpdateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  Value<int> id,
  Value<int> accountId,
  Value<String> action,
  Value<String> itemIds,
  Value<DateTime> createdAt,
  Value<int> retryCount,
});

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemIds => $composableBuilder(
      column: $table.itemIds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemIds => $composableBuilder(
      column: $table.itemIds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get itemIds =>
      $composableBuilder(column: $table.itemIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$SyncQueueItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueItemsTableTableManager(
      _$AppDatabase db, $SyncQueueItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> itemIds = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion(
            id: id,
            accountId: accountId,
            action: action,
            itemIds: itemIds,
            createdAt: createdAt,
            retryCount: retryCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int accountId,
            required String action,
            required String itemIds,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion.insert(
            id: id,
            accountId: accountId,
            action: action,
            itemIds: itemIds,
            createdAt: createdAt,
            retryCount: retryCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$RemoteIdMappingsTableCreateCompanionBuilder
    = RemoteIdMappingsCompanion Function({
  Value<int> id,
  required int accountId,
  required String localType,
  required int localId,
  required String remoteId,
});
typedef $$RemoteIdMappingsTableUpdateCompanionBuilder
    = RemoteIdMappingsCompanion Function({
  Value<int> id,
  Value<int> accountId,
  Value<String> localType,
  Value<int> localId,
  Value<String> remoteId,
});

class $$RemoteIdMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localType => $composableBuilder(
      column: $table.localType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));
}

class $$RemoteIdMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localType => $composableBuilder(
      column: $table.localType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));
}

class $$RemoteIdMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get localType =>
      $composableBuilder(column: $table.localType, builder: (column) => column);

  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);
}

class $$RemoteIdMappingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemoteIdMappingsTable,
    RemoteIdMapping,
    $$RemoteIdMappingsTableFilterComposer,
    $$RemoteIdMappingsTableOrderingComposer,
    $$RemoteIdMappingsTableAnnotationComposer,
    $$RemoteIdMappingsTableCreateCompanionBuilder,
    $$RemoteIdMappingsTableUpdateCompanionBuilder,
    (
      RemoteIdMapping,
      BaseReferences<_$AppDatabase, $RemoteIdMappingsTable, RemoteIdMapping>
    ),
    RemoteIdMapping,
    PrefetchHooks Function()> {
  $$RemoteIdMappingsTableTableManager(
      _$AppDatabase db, $RemoteIdMappingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteIdMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteIdMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteIdMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<String> localType = const Value.absent(),
            Value<int> localId = const Value.absent(),
            Value<String> remoteId = const Value.absent(),
          }) =>
              RemoteIdMappingsCompanion(
            id: id,
            accountId: accountId,
            localType: localType,
            localId: localId,
            remoteId: remoteId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int accountId,
            required String localType,
            required int localId,
            required String remoteId,
          }) =>
              RemoteIdMappingsCompanion.insert(
            id: id,
            accountId: accountId,
            localType: localType,
            localId: localId,
            remoteId: remoteId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemoteIdMappingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemoteIdMappingsTable,
    RemoteIdMapping,
    $$RemoteIdMappingsTableFilterComposer,
    $$RemoteIdMappingsTableOrderingComposer,
    $$RemoteIdMappingsTableAnnotationComposer,
    $$RemoteIdMappingsTableCreateCompanionBuilder,
    $$RemoteIdMappingsTableUpdateCompanionBuilder,
    (
      RemoteIdMapping,
      BaseReferences<_$AppDatabase, $RemoteIdMappingsTable, RemoteIdMapping>
    ),
    RemoteIdMapping,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$FeedItemsTableTableManager get feedItems =>
      $$FeedItemsTableTableManager(_db, _db.feedItems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaggedItemsTableTableManager get taggedItems =>
      $$TaggedItemsTableTableManager(_db, _db.taggedItems);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$FiltersTableTableManager get filters =>
      $$FiltersTableTableManager(_db, _db.filters);
  $$ScrollPositionsTableTableManager get scrollPositions =>
      $$ScrollPositionsTableTableManager(_db, _db.scrollPositions);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$SyncAccountsTableTableManager get syncAccounts =>
      $$SyncAccountsTableTableManager(_db, _db.syncAccounts);
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$RemoteIdMappingsTableTableManager get remoteIdMappings =>
      $$RemoteIdMappingsTableTableManager(_db, _db.remoteIdMappings);
}

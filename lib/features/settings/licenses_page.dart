import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:reeder/l10n/app_localizations.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/reeder_scaffold.dart';
import '../../shared/widgets/reeder_nav_bar.dart';
import '../../shared/widgets/reeder_list_tile.dart';

/// A package and the license entries that apply to it.
class LicenseGroup {
  final String packageName;
  final List<LicenseEntry> entries;

  const LicenseGroup(this.packageName, this.entries);
}

/// Open source licenses list page.
///
/// The app uses [WidgetsApp] (not [MaterialApp]), so Flutter's built-in
/// `showLicensePage` is unavailable. This reads [LicenseRegistry] directly
/// and renders a Reeder-styled list grouped by package.
class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  late final Future<List<LicenseGroup>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadGroups();
  }

  Future<List<LicenseGroup>> _loadGroups() async {
    final byPackage = <String, List<LicenseEntry>>{};
    await for (final entry in LicenseRegistry.licenses) {
      for (final pkg in entry.packages) {
        byPackage.putIfAbsent(pkg, () => []).add(entry);
      }
    }
    final groups = byPackage.entries
        .map((e) => LicenseGroup(e.key, e.value))
        .toList()
      ..sort((a, b) =>
          a.packageName.toLowerCase().compareTo(b.packageName.toLowerCase()));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ReederScaffold(
      navBar: ReederNavBar(
        title: l10n.openSourceLicenses,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: FutureBuilder<List<LicenseGroup>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                l10n.loading,
                style: theme.typography.body.copyWith(
                  color: theme.secondaryTextColor,
                ),
              ),
            );
          }
          final groups = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingS,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ReederListTile(
                title: group.packageName,
                subtitle: '${group.entries.length}',
                showDisclosure: true,
                showSeparator: index != groups.length - 1,
                onTap: () => context.pushNamed(
                  'licenseDetail',
                  extra: group,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Detail page showing the full license text for a single package.
class LicenseDetailPage extends StatelessWidget {
  final LicenseGroup group;

  const LicenseDetailPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = ReederTheme.of(context);

    final paragraphs = <LicenseParagraph>[];
    for (final entry in group.entries) {
      paragraphs.addAll(entry.paragraphs);
    }

    return ReederScaffold(
      navBar: ReederNavBar(
        title: group.packageName,
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          final p = paragraphs[index];
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : AppDimensions.spacingS,
              left: (p.indent == LicenseParagraph.centeredIndent
                      ? 0
                      : p.indent * 8)
                  .toDouble(),
            ),
            child: Text(
              p.text,
              textAlign: p.indent == LicenseParagraph.centeredIndent
                  ? TextAlign.center
                  : TextAlign.start,
              style: theme.typography.summary.copyWith(
                color: theme.secondaryTextColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          );
        },
      ),
    );
  }
}

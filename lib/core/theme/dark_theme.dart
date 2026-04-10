import '../constants/app_colors.dart';
import 'app_theme.dart';

/// Dark theme instance for the Reeder app.
///
/// Background: #1C1C1E, Primary text: #FFFFFF, Accent: #0A84FF
final ReederThemeData darkTheme = ReederThemeData(
  backgroundColor: AppColors.darkBackground,
  secondaryBackgroundColor: AppColors.darkSecondaryBackground,
  primaryTextColor: AppColors.darkPrimaryText,
  secondaryTextColor: AppColors.darkSecondaryText,
  tertiaryTextColor: AppColors.darkTertiaryText,
  accentColor: AppColors.darkAccent,
  separatorColor: AppColors.darkSeparator,
  cardBackgroundColor: AppColors.darkCardBackground,
  iconColor: AppColors.darkIcon,
  activeIconColor: AppColors.darkActiveIcon,
  destructiveColor: AppColors.darkDestructive,
  successColor: AppColors.darkSuccess,
  warningColor: AppColors.darkWarning,
  typography: ReederTypography.fromColors(
    primaryText: AppColors.darkPrimaryText,
    secondaryText: AppColors.darkSecondaryText,
    accentColor: AppColors.darkAccent,
  ),
  isDark: true,
  mode: ReederThemeMode.dark,
);

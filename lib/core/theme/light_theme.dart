import '../constants/app_colors.dart';
import 'app_theme.dart';

/// Light theme instance for the Reeder app.
///
/// Background: #FFFFFF, Primary text: #1C1C1E, Accent: #007AFF
final ReederThemeData lightTheme = ReederThemeData(
  backgroundColor: AppColors.lightBackground,
  secondaryBackgroundColor: AppColors.lightSecondaryBackground,
  primaryTextColor: AppColors.lightPrimaryText,
  secondaryTextColor: AppColors.lightSecondaryText,
  tertiaryTextColor: AppColors.lightTertiaryText,
  accentColor: AppColors.lightAccent,
  separatorColor: AppColors.lightSeparator,
  cardBackgroundColor: AppColors.lightCardBackground,
  iconColor: AppColors.lightIcon,
  activeIconColor: AppColors.lightActiveIcon,
  destructiveColor: AppColors.lightDestructive,
  successColor: AppColors.lightSuccess,
  warningColor: AppColors.lightWarning,
  typography: ReederTypography.fromColors(
    primaryText: AppColors.lightPrimaryText,
    secondaryText: AppColors.lightSecondaryText,
    accentColor: AppColors.lightAccent,
  ),
  isDark: false,
  mode: ReederThemeMode.light,
);

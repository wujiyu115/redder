import '../constants/app_colors.dart';
import 'app_theme.dart';

/// OLED Black theme instance for the Reeder app.
///
/// Pure black background (#000000) optimized for OLED displays.
final ReederThemeData oledTheme = ReederThemeData(
  backgroundColor: AppColors.oledBackground,
  secondaryBackgroundColor: AppColors.oledSecondaryBackground,
  primaryTextColor: AppColors.oledPrimaryText,
  secondaryTextColor: AppColors.oledSecondaryText,
  tertiaryTextColor: AppColors.oledTertiaryText,
  accentColor: AppColors.oledAccent,
  separatorColor: AppColors.oledSeparator,
  cardBackgroundColor: AppColors.oledCardBackground,
  iconColor: AppColors.oledIcon,
  activeIconColor: AppColors.oledActiveIcon,
  destructiveColor: AppColors.darkDestructive,
  successColor: AppColors.darkSuccess,
  warningColor: AppColors.darkWarning,
  typography: ReederTypography.fromColors(
    primaryText: AppColors.oledPrimaryText,
    secondaryText: AppColors.oledSecondaryText,
    accentColor: AppColors.oledAccent,
  ),
  isDark: true,
  mode: ReederThemeMode.oled,
);

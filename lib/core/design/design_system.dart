/// Sistema de diseño de PantryScanner.
///
/// **Single import para acceso a todo el sistema:**
/// ```dart
/// import 'package:pantry_scanner/core/design/design_system.dart';
/// ```
///
/// Esto te da acceso a:
/// - `AppColors` — paleta completa light + dark
/// - `AppSpacing` — escala 4pt
/// - `AppRadius` — border radius
/// - `AppTypography` — escala tipográfica
/// - `AppElevation` — sombras tokenizadas
/// - `AppDuration` — duraciones de animación
/// - `AppBreakpoints` — layout responsivo
/// - `AppHaptics` — feedback háptico semántico
/// - `PlatformAdaptive` — helpers iOS/Android
/// - `AppThemeLight` / `AppThemeDark` — ThemeData listos
library;

export 'platform/app_haptics.dart';
export 'platform/platform_adaptive.dart';
export 'theme/app_theme_dark.dart';
export 'theme/app_theme_light.dart';
export 'tokens/app_breakpoints.dart';
export 'tokens/app_colors.dart';
export 'tokens/app_duration.dart';
export 'tokens/app_elevation.dart';
export 'tokens/app_radius.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_typography.dart';
export 'widgets/brand_gradient_button.dart';
export 'widgets/empty_state.dart';
export 'widgets/split_hero_scaffold.dart';

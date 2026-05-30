import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../data/services/local_notification_service.dart';
import '../../domain/entities/notification_settings.dart';
import '../providers/notification_settings_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  static const List<_CategorySpec> _categories = <_CategorySpec>[
    _CategorySpec('Lácteos', Icons.egg_outlined),
    _CategorySpec('Carnes', Icons.kebab_dining_outlined),
    _CategorySpec('Frutas y verduras', Icons.eco_outlined),
    _CategorySpec('Enlatados', Icons.inventory_2_outlined),
    _CategorySpec('Bebidas', Icons.local_drink_outlined),
    _CategorySpec('Snacks', Icons.fastfood_outlined),
    _CategorySpec('Cereales', Icons.breakfast_dining_outlined),
    _CategorySpec('Condimentos', Icons.soup_kitchen_outlined),
    _CategorySpec('Sin categoría', Icons.category_outlined),
  ];

  Future<void> _save(NotificationSettings settings) async {
    try {
      await ref.read(saveNotificationSettingsUseCaseProvider).call(
            settings.copyWith(updatedAt: DateTime.now()),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la configuración: $e'),
          backgroundColor: AppColors.dangerStrong,
        ),
      );
    }
  }

  Future<bool> _ensurePermission() async {
    if (kIsWeb) return true;
    final bool granted =
        await LocalNotificationService.instance.requestPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dangerStrong,
          content: Text(
            'Permiso denegado. Actívalo en la configuración del sistema.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return granted;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NotificationSettings> settingsAsync =
        ref.watch(notificationSettingsProvider);
    final PaletteSpec p = context.palette;

    return Scaffold(
      backgroundColor: p.bg,
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace _) => _ErrorState(
          message: 'No se pudo cargar la configuración.',
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
        data: (NotificationSettings settings) {
          return CustomScrollView(
            slivers: <Widget>[
              _SettingsHero(enabled: settings.enabled),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _MasterToggle(
                      enabled: settings.enabled,
                      onChanged: (bool value) async {
                        if (value) {
                          final bool granted = await _ensurePermission();
                          if (!granted) return;
                        }
                        AppHaptics.tap();
                        _save(settings.copyWith(enabled: value));
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AnimatedOpacity(
                      opacity: settings.enabled ? 1 : 0.4,
                      duration: AppDuration.medium,
                      child: IgnorePointer(
                        ignoring: !settings.enabled,
                        child: Column(
                          children: <Widget>[
                            _GlobalThresholdCard(
                              value: settings.globalDaysBefore,
                              onChanged: (int days) {
                                AppHaptics.select();
                                _save(settings.copyWith(globalDaysBefore: days));
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _TimeCard(
                              time: settings.preferredTime,
                              onPick: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: settings.preferredTime,
                                  helpText: 'Hora preferida para alertas',
                                );
                                if (picked == null) return;
                                AppHaptics.confirm();
                                _save(settings.copyWith(
                                  preferredHour: picked.hour,
                                  preferredMinute: picked.minute,
                                ));
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _CategoryRulesCard(
                              categories: _categories,
                              overrides: settings.categoryOverrides,
                              onChanged: (String category, int? value) {
                                AppHaptics.select();
                                final Map<String, int> overrides =
                                    Map<String, int>.from(
                                  settings.categoryOverrides,
                                );
                                if (value == null) {
                                  overrides.remove(category);
                                } else {
                                  overrides[category] = value;
                                }
                                _save(settings.copyWith(
                                  categoryOverrides: overrides,
                                ));
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const _InstantInfoBanner(),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero gradient with back button + "ver inbox" shortcut
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsHero extends StatelessWidget {
  const _SettingsHero({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppRadius.xxxl),
            bottomRight: Radius.circular(AppRadius.xxxl),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPad + AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleIconBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    context.pop();
                  },
                ),
                const Spacer(),
                _CircleIconBtn(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Ver notificaciones recibidas',
                  onTap: () {
                    AppHaptics.tap();
                    context.push(AppRoutes.notificationsInbox);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Alertas',
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              enabled
                  ? 'Configura cuándo y cómo recibir avisos de tu despensa.'
                  : 'Las alertas están pausadas. Actívalas para no perder ningún producto.',
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget child = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: child) : child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Master toggle (always interactive)
// ─────────────────────────────────────────────────────────────────────────────
class _MasterToggle extends StatelessWidget {
  const _MasterToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFEF4444), Color(0xFFC0392B)],
              )
            : null,
        color: enabled ? null : p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(
          color: enabled
              ? Colors.transparent
              : p.outline.withValues(alpha: 0.6),
        ),
        boxShadow: enabled ? AppElevation.modal : AppElevation.card,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.22)
                  : p.surfaceMuted,
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: enabled ? Colors.white : p.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  enabled ? 'Alertas activas' : 'Alertas pausadas',
                  style: AppTypography.headingSm.copyWith(
                    color: enabled ? Colors.white : p.textBody,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'Te avisaremos antes de que algo se venza.'
                      : 'Actívalas para recibir avisos de vencimiento.',
                  style: AppTypography.bodyXs.copyWith(
                    color: enabled
                        ? Colors.white.withValues(alpha: 0.85)
                        : p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable card shell
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.brandTintSoft,
                  borderRadius: AppRadius.brMs,
                ),
                child: Icon(icon, color: p.brandPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.headingSm.copyWith(
                        color: p.textBody,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style:
                          AppTypography.bodyXs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Global threshold (pills)
// ─────────────────────────────────────────────────────────────────────────────
class _GlobalThresholdCard extends StatelessWidget {
  const _GlobalThresholdCard({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Umbral global',
      subtitle: 'Avisar X días antes de que algo se venza.',
      icon: Icons.bolt_rounded,
      child: Row(
        children: <Widget>[
          for (final int days in const <int>[1, 3, 7]) ...<Widget>[
            Expanded(
              child: _ThresholdPill(
                label: days == 1 ? '1 día' : '$days días',
                selected: value == days,
                onTap: () => onChanged(days),
              ),
            ),
            if (days != 7) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ThresholdPill extends StatelessWidget {
  const _ThresholdPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
        decoration: BoxDecoration(
          color: selected ? p.brandPrimary : p.surfaceMuted,
          borderRadius: AppRadius.brLg,
          border: Border.all(
            color: selected ? p.brandPrimary : p.outlineSoft,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: selected ? Colors.white : p.textBody,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time card
// ─────────────────────────────────────────────────────────────────────────────
class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.time, required this.onPick});

  final TimeOfDay time;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return _SettingsCard(
      title: 'Hora preferida',
      subtitle: 'Las alertas se enviarán a esta hora.',
      icon: Icons.access_time_rounded,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              time.format(context),
              style: AppTypography.displayMd.copyWith(
                color: p.brandPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
            ),
          ),
          GestureDetector(
            onTap: onPick,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: p.brandTintSoft,
                borderRadius: AppRadius.brPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.edit_rounded,
                      color: p.brandPrimary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Cambiar',
                    style: AppTypography.labelMd.copyWith(
                      color: p.brandPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category rules
// ─────────────────────────────────────────────────────────────────────────────
class _CategorySpec {
  const _CategorySpec(this.name, this.icon);
  final String name;
  final IconData icon;
}

class _CategoryRulesCard extends StatelessWidget {
  const _CategoryRulesCard({
    required this.categories,
    required this.overrides,
    required this.onChanged,
  });

  final List<_CategorySpec> categories;
  final Map<String, int> overrides;
  final void Function(String category, int? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return _SettingsCard(
      title: 'Reglas por categoría',
      subtitle: 'Sobrescribe el umbral global para una categoría puntual.',
      icon: Icons.category_outlined,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < categories.length; i++) ...<Widget>[
            _CategoryRow(
              spec: categories[i],
              value: overrides[categories[i].name],
              onChanged: (int? v) => onChanged(categories[i].name, v),
            ),
            if (i != categories.length - 1)
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                height: 1,
                color: p.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final _CategorySpec spec;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final bool isOverride = value != null;

    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isOverride
                ? p.brandTintSoft
                : p.surfaceMuted,
            borderRadius: AppRadius.brMs,
          ),
          child: Icon(
            spec.icon,
            color: isOverride ? p.brandPrimary : p.textMuted,
            size: 17,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            spec.name,
            style: AppTypography.bodyMd.copyWith(
              color: p.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _CategoryValueDropdown(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _CategoryValueDropdown extends StatelessWidget {
  const _CategoryValueDropdown({
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final bool isOverride = value != null;
    final String label = value == null
        ? 'Global'
        : value == 1
            ? '1 día'
            : '$value días';

    return PopupMenuButton<int?>(
      tooltip: 'Cambiar umbral',
      color: p.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.brLg,
        side: BorderSide(color: p.outline),
      ),
      onSelected: onChanged,
      itemBuilder: (BuildContext _) => const <PopupMenuEntry<int?>>[
        PopupMenuItem<int?>(value: null, child: Text('Usar global')),
        PopupMenuItem<int?>(value: 1, child: Text('1 día')),
        PopupMenuItem<int?>(value: 3, child: Text('3 días')),
        PopupMenuItem<int?>(value: 7, child: Text('7 días')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isOverride ? p.brandPrimary : p.surfaceMuted,
          borderRadius: AppRadius.brPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isOverride ? Colors.white : p.textBody,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: isOverride ? Colors.white : p.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Instant info
// ─────────────────────────────────────────────────────────────────────────────
class _InstantInfoBanner extends StatelessWidget {
  const _InstantInfoBanner();

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.ms,
      ),
      decoration: BoxDecoration(
        color: p.brandTintSoft,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: p.brandPrimary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.flash_on_rounded, color: p.brandPrimary, size: 18),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              'Los cambios se aplican al instante en tus alertas.',
              style: AppTypography.bodyXs.copyWith(
                color: p.textBody,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded,
                color: AppColors.dangerStrong, size: 36),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: p.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

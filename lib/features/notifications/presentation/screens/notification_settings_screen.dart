import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    extends ConsumerState<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final List<String> _categories = const <String>[
    'Lácteos',
    'Carnes',
    'Frutas y verduras',
    'Enlatados',
    'Bebidas',
    'Snacks',
    'Cereales',
    'Condimentos',
    'Sin categoría',
  ];

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

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
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Requests notification permission on Android 13+ before enabling.
  /// Returns `true` if the permission was granted (or we're on web).
  Future<bool> _ensurePermission() async {
    if (kIsWeb) return true;
    final bool granted =
        await LocalNotificationService.instance.requestPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Permiso de notificaciones denegado. '
            'Actívalo en la configuración del sistema.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: 'Entendido',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
    return granted;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.palette.bg,
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace st) => _ErrorState(
          message: 'No se pudo cargar la configuración.',
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
        data: (NotificationSettings settings) {
          return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Alertas inteligentes',
                            style: AppTypography.displayLg.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Define cuándo quieres recibir avisos de vencimiento y ajusta reglas por categoría.',
                            style: AppTypography.bodyMd.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md + 2),
                          _SettingsCard(
                            title: 'Activar alertas',
                            subtitle:
                              'Puedes pausar todas las notificaciones sin perder tu configuración.',
                            child: SwitchListTile.adaptive(
                              value: settings.enabled,
                              onChanged: (bool value) async {
                                if (value) {
                                  final bool granted =
                                      await _ensurePermission();
                                  if (!granted) return;
                                }
                                _save(
                                  settings.copyWith(enabled: value),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Notificaciones de vencimiento',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Recibe alertas antes de que un producto expire',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Opacity(
                            opacity: settings.enabled ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !settings.enabled,
                              child: Column(
                                children: <Widget>[
                                  _SettingsCard(
                                    title: 'Umbral global',
                                    subtitle:
                                      'Se aplica a todas las categorías sin regla especial.',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(height: 4),
                                        SegmentedButton<int>(
                                          segments: const <ButtonSegment<int>>[
                                            ButtonSegment<int>(
                                              value: 1,
                                              label: Text('1 día'),
                                            ),
                                            ButtonSegment<int>(
                                              value: 3,
                                              label: Text('3 días'),
                                            ),
                                            ButtonSegment<int>(
                                              value: 7,
                                              label: Text('7 días'),
                                            ),
                                          ],
                                          selected: <int>{
                                            settings.globalDaysBefore
                                          },
                                          onSelectionChanged:
                                              (Set<int> selection) {
                                            if (selection.isEmpty) return;
                                            _save(
                                              settings.copyWith(
                                                globalDaysBefore:
                                                    selection.first,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SettingsCard(
                                    title: 'Reglas por categoría',
                                    subtitle:
                                      'Opcional. Si no eliges nada, se usa el umbral global.',
                                    child: Column(
                                      children: _categories
                                          .map(
                                            (String category) =>
                                                _CategoryRuleRow(
                                              category: category,
                                              value: settings
                                                  .categoryOverrides[category],
                                              onChanged: (int? value) {
                                                final Map<String, int>
                                                    overrides =
                                                    Map<String, int>.from(
                                                  settings.categoryOverrides,
                                                );
                                                if (value == null) {
                                                  overrides.remove(category);
                                                } else {
                                                  overrides[category] = value;
                                                }
                                                _save(
                                                  settings.copyWith(
                                                    categoryOverrides:
                                                        overrides,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SettingsCard(
                                    title: 'Horario preferido',
                                    subtitle:
                                      'Las alertas se enviarán a la hora que elijas.',
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            settings.preferredTime
                                                .format(context),
                                            style: AppTypography.headingLg.copyWith(
                                              color: colors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final TimeOfDay? picked =
                                                await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  settings.preferredTime,
                                              helpText:
                                                  'Selecciona la hora',
                                            );
                                            if (picked == null) return;
                                            _save(
                                              settings.copyWith(
                                                preferredHour: picked.hour,
                                                preferredMinute: picked.minute,
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.schedule_outlined),
                                          label: const Text('Cambiar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.primary
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colors.primary
                                            .withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.flash_on_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Los cambios se aplican al instante en tus alertas.',
                                            style: TextStyle(
                                              color: colors.onSurface
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(
              title!,
              style: AppTypography.headingSm.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _CategoryRuleRow extends StatelessWidget {
  const _CategoryRuleRow({
    required this.category,
    required this.value,
    required this.onChanged,
  });

  final String category;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: DropdownButtonFormField<int?>(
              initialValue: value,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: const <DropdownMenuItem<int?>>[
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Global'),
                ),
                DropdownMenuItem<int?>(
                  value: 1,
                  child: Text('1 día'),
                ),
                DropdownMenuItem<int?>(
                  value: 3,
                  child: Text('3 días'),
                ),
                DropdownMenuItem<int?>(
                  value: 7,
                  child: Text('7 días'),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, color: colors.error, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../inventory/presentation/widgets/inventory_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: InventoryTokens.bg,
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
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? <Color>[
                              colors.surface,
                              colors.surface.withValues(alpha: 0.9),
                              colors.primary.withValues(alpha: 0.12),
                            ]
                          : <Color>[
                              InventoryTokens.bg,
                              InventoryTokens.bgMuted,
                              const Color(0xFFE7EFE2),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
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
                            style: GoogleFonts.epilogue(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Define cuándo quieres recibir avisos de vencimiento y ajusta reglas por categoría.',
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.65),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _SettingsCard(
                            title: 'Activar alertas',
                            subtitle:
                              'Puedes pausar todas las notificaciones sin perder tu configuración.',
                            child: SwitchListTile.adaptive(
                              value: settings.enabled,
                              onChanged: (bool value) => _save(
                                settings.copyWith(enabled: value),
                              ),
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
                                            style: GoogleFonts.epilogue(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: colors.onSurface,
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
                ),
              ),
            ],
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
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
              value: value,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../app/router/app_router.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const String _kSeen = 'onboarding.seen';

  int _currentPage = 0;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;

  static const List<_SlideData> _slides = <_SlideData>[
    _SlideData(
      title: 'Bienvenido a Foodly',
      description:
          'Tu asistente para gestionar alimentos en casa. Sin desperdicio, sin olvidos.',
    ),
    _SlideData(
      title: 'Controla tu despensa',
      description:
          'Escanea productos, registra cantidades y recibe alertas antes de que caduquen.',
    ),
    _SlideData(
      title: 'Cocina con lo que tienes',
      description:
          'Te sugerimos recetas según los ingredientes que ya tienes disponibles en casa.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: AppDuration.heroIn,
    )..forward();
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    AppHaptics.confirm();
    await ref.read(sharedPreferencesProvider).setBool(_kSeen, true);
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    AppHaptics.tap();
    setState(() => _currentPage++);
  }

  void _prev() {
    setState(() => _currentPage--);
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final double screenH = MediaQuery.sizeOf(context).height;
    final double topPad = MediaQuery.paddingOf(context).top;
    final double bottomPad = MediaQuery.paddingOf(context).bottom;
    final double heroH = screenH * 0.44;
    final bool isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.brandPrimaryDark,
      body: FadeTransition(
        opacity: _entryFade,
        child: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails d) {
            final double? v = d.primaryVelocity;
            if (v == null) return;
            if (v < -200 && !isLast) _next();
            if (v > 200 && _currentPage > 0) _prev();
          },
          child: Stack(
            children: <Widget>[
              // 1 — Gradient background (fijo, no se mueve)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(gradient: AppColors.heroGradient),
                ),
              ),

              // 2 — Hero con logo (fijo, igual para todos los slides)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: _FixedHero(topPadding: topPad),
              ),

              // 3 — Card blanca (fija, solo cambia el texto)
              Positioned(
                left: 0,
                right: 0,
                top: heroH - AppRadius.xxxl,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: AppRadius.sheetTop,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl + AppRadius.xxxl,
                      AppSpacing.lg,
                      bottomPad + AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Solo el texto cambia con animación
                        AnimatedSwitcher(
                          duration: AppDuration.medium,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder:
                              (Widget child, Animation<double> anim) {
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.08, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            );
                          },
                          child: _SlideText(
                            key: ValueKey<int>(_currentPage),
                            slide: _slides[_currentPage],
                            palette: p,
                          ),
                        ),
                        const Spacer(),
                        _DotsIndicator(
                          count: _slides.length,
                          current: _currentPage,
                          palette: p,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BrandGradientButton(
                          label: isLast ? 'Comenzar' : 'Siguiente',
                          onPressed: isLast ? _finish : _next,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4 — Botón saltar (top-right)
              Positioned(
                top: topPad + AppSpacing.xs,
                right: AppSpacing.sm,
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: AppDuration.medium,
                  child: IgnorePointer(
                    ignoring: isLast,
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        'Saltar',
                        style: AppTypography.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({required this.title, required this.description});
  final String title;
  final String description;
}

class _FixedHero extends StatelessWidget {
  const _FixedHero({required this.topPadding});
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.brXxl,
              boxShadow: AppElevation.heroIcon,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Image.asset(
              'assets/branding/icon_symbol.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Foodly',
            style: AppTypography.displaySm.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideText extends StatelessWidget {
  const _SlideText({super.key, required this.slide, required this.palette});
  final _SlideData slide;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: AppTypography.displayMd.copyWith(color: palette.textBody),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            color: palette.textMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.palette,
  });
  final int count;
  final int current;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: AppDuration.medium,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: active ? 28.0 : 8.0,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.brandPrimary : palette.outline,
            borderRadius: AppRadius.brPill,
          ),
        );
      }),
    );
  }
}

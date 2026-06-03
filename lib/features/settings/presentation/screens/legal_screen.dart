import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Pantalla de texto legal (términos o privacidad). El contenido se pasa
/// por parámetro, así que el router decide cuál mostrar.
class LegalScreen extends StatelessWidget {
  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  /// Constructor de conveniencia para "Términos y condiciones".
  factory LegalScreen.terms(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return LegalScreen(title: t.legalTermsTitle, body: t.legalTermsBody);
  }

  /// Constructor de conveniencia para "Política de privacidad".
  factory LegalScreen.privacy(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return LegalScreen(title: t.legalPrivacyTitle, body: t.legalPrivacyBody);
  }

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final double topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
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
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _BackBtn(onTap: () {
                        AppHaptics.tap();
                        context.pop();
                      }),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    style: AppTypography.displaySm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: AppRadius.brXl,
                  border: Border.all(color: p.outlineSoft),
                  boxShadow: AppElevation.card,
                ),
                child: Text(
                  body,
                  style: AppTypography.bodyMd.copyWith(
                    color: p.textBody,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 20),
      ),
    );
  }
}

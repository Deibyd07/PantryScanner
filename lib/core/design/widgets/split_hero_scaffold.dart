import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

/// Scaffold con patrón "Split Hero" — pantalla con gradiente arriba y
/// card blanca redondeada abajo.
///
/// Patrón de marca usado en auth (login/register/forgot) y product form.
///
/// **Layout:**
/// ```
/// ┌───────────────────────────┐  ← Hero gradiente
/// │  [Logo / título hero]     │
/// │                           │
/// ├─╮                       ╭─┤  ← Esquinas redondeadas
/// │ ╰───────────────────────╯ │
/// │  [Form card blanca]       │
/// └───────────────────────────┘
/// ```
///
/// La altura del hero es configurable; el resto del espacio lo ocupa la card.
class SplitHeroScaffold extends StatelessWidget {
  const SplitHeroScaffold({
    super.key,
    required this.heroHeight,
    required this.heroContent,
    required this.formContent,
    this.heroTopAlignment = false,
    this.gradient = AppColors.heroGradient,
    this.overlay,
  });

  /// Altura del hero EXCLUYENDO el safe-area top padding (se suma automáticamente).
  final double heroHeight;

  /// Contenido del hero (logo, título). Centrado verticalmente por defecto.
  final Widget heroContent;

  /// Contenido del form (scrollable). Será wrappeado en una card blanca redondeada.
  final Widget formContent;

  /// Si true, el contenido del hero se alinea al top (no centrado).
  final bool heroTopAlignment;

  /// Gradiente del hero. Default: gradiente de marca.
  final LinearGradient gradient;

  /// Overlay opcional sobre todo el scaffold (banner offline, etc).
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    final double bottomPad = MediaQuery.paddingOf(context).bottom;
    final double effectiveHeroHeight = heroHeight + topPad;

    return Scaffold(
      backgroundColor: AppColors.brandPrimaryDark, // fallback para overscroll
      body: Stack(
        children: <Widget>[
          // ── Capa 1: gradiente que cubre toda la pantalla (incluso detrás
          //   de las esquinas redondeadas de la card, para que la curva
          //   nunca revele un color "cortado").
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          ),
          // ── Capa 2: card blanca con tope redondeado, ocupa la zona
          //   inferior. El gradiente sigue siendo visible detrás de la curva.
          Positioned(
            left: 0,
            right: 0,
            top: effectiveHeroHeight,
            bottom: 0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadius.sheetTop,
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPad),
                  child: formContent,
                ),
              ),
            ),
          ),
          // ── Capa 3: contenido del hero (logo, título) por encima del
          //   gradiente, ocupando exactamente la zona del hero.
          Positioned(
            left: 0,
            right: 0,
            top: topPad,
            height: heroHeight,
            child: Align(
              alignment:
                  heroTopAlignment ? Alignment.topCenter : Alignment.center,
              child: heroContent,
            ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

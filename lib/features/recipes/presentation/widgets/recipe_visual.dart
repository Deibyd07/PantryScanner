import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/recipe.dart';

/// Visual de cabecera para una receta. Si [imageUrl] está disponible y carga
/// bien, muestra la imagen; de lo contrario muestra un gradiente coloreado
/// según el tipo de comida con un icono centrado. El [trailing] (típicamente
/// un pill de cobertura) se posiciona arriba-derecha.
///
/// [imageUrl] puede ser una ruta de asset local (empieza con "assets/") o
/// una URL remota. Las recetas del catálogo usan assets locales para
/// garantizar carga instantánea sin red.
class RecipeVisual extends StatelessWidget {
  const RecipeVisual({
    super.key,
    required this.meal,
    this.imageUrl,
    this.trailing,
    this.borderRadius,
  });

  final RecipeMeal meal;
  final String? imageUrl;
  final Widget? trailing;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final _MealVisualSpec spec = _specFor(meal);

    final Widget background;
    if (imageUrl == null || imageUrl!.isEmpty) {
      background = _gradientFallback(spec);
    } else if (imageUrl!.startsWith('assets/')) {
      background = Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _gradientFallback(spec),
      );
    } else {
      background = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 800,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        httpHeaders: const <String, String>{
          'User-Agent': 'PantryScanner/1.0 (Flutter; Android)',
        },
        placeholder: (_, __) => _gradientFallback(spec),
        errorWidget: (_, __, ___) => _gradientFallback(spec),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: background),
          if (trailing != null)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: trailing!,
            ),
        ],
      ),
    );
  }

  Widget _gradientFallback(_MealVisualSpec spec) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[spec.colorA, spec.colorB],
        ),
      ),
      child: Center(
        child: Icon(
          spec.icon,
          color: Colors.white.withValues(alpha: 0.78),
          size: 56,
        ),
      ),
    );
  }

  _MealVisualSpec _specFor(RecipeMeal meal) {
    switch (meal) {
      case RecipeMeal.desayuno:
        return const _MealVisualSpec(
          colorA: Color(0xFFFFB74D),
          colorB: Color(0xFFE65100),
          icon: Icons.free_breakfast_rounded,
        );
      case RecipeMeal.almuerzo:
        return const _MealVisualSpec(
          colorA: Color(0xFFEF5350),
          colorB: Color(0xFFB71C1C),
          icon: Icons.lunch_dining_rounded,
        );
      case RecipeMeal.cena:
        return const _MealVisualSpec(
          colorA: Color(0xFF7E57C2),
          colorB: Color(0xFF4527A0),
          icon: Icons.dinner_dining_rounded,
        );
      case RecipeMeal.snack:
        return const _MealVisualSpec(
          colorA: Color(0xFF26A69A),
          colorB: Color(0xFF00695C),
          icon: Icons.cookie_rounded,
        );
      case RecipeMeal.postre:
        return const _MealVisualSpec(
          colorA: Color(0xFFEC407A),
          colorB: Color(0xFFAD1457),
          icon: Icons.icecream_rounded,
        );
    }
  }
}

class _MealVisualSpec {
  const _MealVisualSpec({
    required this.colorA,
    required this.colorB,
    required this.icon,
  });
  final Color colorA;
  final Color colorB;
  final IconData icon;
}

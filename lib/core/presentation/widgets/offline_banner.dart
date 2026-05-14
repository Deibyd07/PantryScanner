import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connectivity_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Non-intrusive offline indicator banner.
// Animates in/out at the top of the screen when connectivity changes.
// ─────────────────────────────────────────────────────────────────────────────
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> offlineState = ref.watch(isOfflineProvider);

    // During initial load we have no connectivity info yet — hide the banner.
    final bool isOffline = offlineState.valueOrNull ?? false;

    return AnimatedSlide(
      offset: isOffline ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isOffline ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          width: double.infinity,
          color: const Color(0xFFB71C1C),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Sin conexión a internet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

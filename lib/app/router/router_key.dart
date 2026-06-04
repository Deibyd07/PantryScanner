import 'package:flutter/material.dart';

/// Clave global del navigator raíz. La usa GoRouter y LocalNotificationService
/// para navegar desde callbacks estáticos (fuera del árbol de widgets).
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

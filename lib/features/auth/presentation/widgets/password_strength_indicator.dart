import 'package:flutter/material.dart';

/// Animated password-strength indicator bar.
/// Shows a colored bar that grows from 0 → 100 % based on [strength].
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  /// Returns a value between 0.0 and 1.0.
  double get strength {
    if (password.isEmpty) return 0;
    double s = 0;
    if (password.length >= 8) s += 0.25;
    if (password.length >= 12) s += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) s += 0.25;
    if (RegExp(r'[!@#\$%\^&\*\(\)\-_=\+\[\]\{\};:,\.<>\?/\\|`~]')
        .hasMatch(password)) {
      s += 0.15;
    }
    return s.clamp(0.0, 1.0);
  }

  Color get _color {
    final double s = strength;
    if (s <= 0.25) return const Color(0xFFFF4B4B);
    if (s <= 0.5) return const Color(0xFFFF9F43);
    if (s <= 0.75) return const Color(0xFFFECA57);
    return const Color(0xFF2EA87E);
  }

  String get _label {
    final double s = strength;
    if (s <= 0) return '';
    if (s <= 0.25) return 'Débil';
    if (s <= 0.5) return 'Regular';
    if (s <= 0.75) return 'Buena';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Animated bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    widthFactor: strength,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            child: Text(_label),
          ),
        ],
      ),
    );
  }
}

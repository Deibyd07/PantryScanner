import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../providers/auth_providers.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final AnimationController _staggerCtrl;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(vsync: this, duration: AppDuration.heroLong)..forward();
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);

    _staggerCtrl = AnimationController(vsync: this, duration: AppDuration.staggerLong);
    _slideAnims = List<Animation<Offset>>.generate(5, (int i) {
      final double start = 0.08 + i * 0.1;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)));
    });
    _fadeAnims = List<Animation<double>>.generate(5, (int i) {
      final double start = 0.08 + i * 0.1;
      final double end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOut)));
    });
    _staggerCtrl.forward();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _staggerCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.warning();
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(registerWithEmailUseCaseProvider).call(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
      if (mounted) AppHaptics.success();
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(color: Colors.white),
            ),
          ),
        ]),
        backgroundColor: AppColors.dangerStrong,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    return SplitHeroScaffold(
      heroHeight: 180,
      heroContent: FadeTransition(opacity: _heroFade, child: _buildHero()),
      formContent: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg + 4,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Back button + title
            Row(
              children: <Widget>[
                _BackButton(isLoading: _isLoading, palette: p),
                const SizedBox(width: AppSpacing.ms),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Crear cuenta',
                      style: AppTypography.displayMd.copyWith(
                        color: p.textBody,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Completa tus datos para registrarte',
                      style: AppTypography.bodyXs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Name
                    _animatedItem(
                      index: 0,
                      child: TextFormField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const <String>[AutofillHints.name],
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                        style: AppTypography.bodyMd.copyWith(color: p.textBody, fontWeight: FontWeight.w600),
                        cursorColor: p.brandPrimary,
                        decoration: _field(p, label: 'Nombre completo', icon: Icons.person_outline_rounded),
                        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md - 2),

                    // Email
                    _animatedItem(
                      index: 1,
                      child: TextFormField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        validator: _validateEmail,
                        style: AppTypography.bodyMd.copyWith(color: p.textBody, fontWeight: FontWeight.w600),
                        cursorColor: p.brandPrimary,
                        decoration: _field(p, label: 'Correo electrónico', icon: Icons.email_outlined),
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md - 2),

                    // Password + strength
                    _animatedItem(
                      index: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const <String>[AutofillHints.newPassword],
                            validator: _validatePassword,
                            style: AppTypography.bodyMd.copyWith(color: p.textBody, fontWeight: FontWeight.w600),
                            cursorColor: p.brandPrimary,
                            decoration: _field(
                              p,
                              label: 'Contraseña',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: p.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                          ),
                          PasswordStrengthIndicator(password: _passwordCtrl.text),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md - 2),

                    // Confirm password
                    _animatedItem(
                      index: 3,
                      child: TextFormField(
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.newPassword],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                          if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                        style: AppTypography.bodyMd.copyWith(color: p.textBody, fontWeight: FontWeight.w600),
                        cursorColor: p.brandPrimary,
                        decoration: _field(
                          p,
                          label: 'Confirmar contraseña',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(
                              _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: p.textMuted,
                              size: 20,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (_) => _register(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Register button
                    _animatedItem(
                      index: 4,
                      child: BrandGradientButton(
                        label: 'Crear cuenta',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _register,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.ml + 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: AppTypography.bodyMd.copyWith(
                            color: p.textMuted.withValues(alpha: 0.8),
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: p.brandPrimary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Iniciar sesión',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: p.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(18)),
            boxShadow: AppElevation.heroIcon,
          ),
          child: const Icon(Icons.person_add_rounded, color: AppColors.brandPrimary, size: 30),
        ),
        const SizedBox(height: AppSpacing.ms),
        Text(
          'PantryScanner',
          style: AppTypography.displaySm.copyWith(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 3),
        Text(
          'Únete y organiza tu despensa',
          style: AppTypography.bodyXs.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  InputDecoration _field(
    PaletteSpec p, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: p.brandPrimary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: p.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 18,
      ),
      labelStyle: AppTypography.labelMd.copyWith(color: p.textMuted),
      floatingLabelStyle: AppTypography.labelSm.copyWith(
        color: p.brandPrimary,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.brLg,
        borderSide: BorderSide(color: p.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.brLg,
        borderSide: BorderSide(color: p.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.brLg,
        borderSide: BorderSide(color: p.brandPrimary, width: 1.8),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brLg,
        borderSide: BorderSide(color: AppColors.dangerStrong),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brLg,
        borderSide: BorderSide(color: AppColors.dangerStrong, width: 1.4),
      ),
      errorStyle: const TextStyle(
        color: AppColors.dangerStrong,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _animatedItem({required int index, required Widget child}) {
    return SlideTransition(
      position: _slideAnims[index],
      child: FadeTransition(opacity: _fadeAnims[index], child: child),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu correo electrónico';
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Formato de correo inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Debe incluir al menos 1 mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Debe incluir al menos 1 número';
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.isLoading, required this.palette});
  final bool isLoading;
  final PaletteSpec palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              AppHaptics.tap();
              context.pop();
            },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: palette.bgMuted,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: palette.outline),
        ),
        child: Icon(Icons.arrow_back_rounded, color: palette.textBody, size: 20),
      ),
    );
  }
}

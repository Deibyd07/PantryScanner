import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../providers/auth_providers.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final AnimationController _staggerCtrl;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: AppDuration.heroLong,
    )..forward();
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: AppDuration.staggerShort,
    );
    _slideAnims = List<Animation<Offset>>.generate(5, (int i) {
      final double start = 0.1 + i * 0.12;
      final double end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _fadeAnims = List<Animation<double>>.generate(5, (int i) {
      final double start = 0.1 + i * 0.12;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _staggerCtrl, curve: Interval(start, end, curve: Curves.easeOut)));
    });
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _staggerCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.warning();
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(loginWithEmailUseCaseProvider).call(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
          );
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(loginWithGoogleUseCaseProvider).call();
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
    final bool anyLoading = _isLoading || _isGoogleLoading;
    final PaletteSpec p = context.palette;

    return SplitHeroScaffold(
      heroHeight: 210,
      heroContent: FadeTransition(opacity: _heroFade, child: _buildHero()),
      formContent: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFormTitle(p),
            const SizedBox(height: AppSpacing.xl - 4),
            Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Email
                    _animatedItem(
                      index: 0,
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

                    // Password
                    _animatedItem(
                      index: 1,
                      child: TextFormField(
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
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
                        onFieldSubmitted: (_) => _loginWithEmail(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: anyLoading ? null : () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          foregroundColor: p.brandPrimary,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: p.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Login button (shimmer compartido)
                    _animatedItem(
                      index: 2,
                      child: BrandGradientButton(
                        label: 'Iniciar sesión',
                        isLoading: _isLoading,
                        onPressed: anyLoading ? null : _loginWithEmail,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Divider
                    _animatedItem(
                      index: 3,
                      child: Row(children: <Widget>[
                        Expanded(child: Divider(color: p.outline.withValues(alpha: 0.8), thickness: 1, height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text(
                            'o continúa con',
                            style: AppTypography.bodyXs.copyWith(
                              color: p.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: p.outline.withValues(alpha: 0.8), thickness: 1, height: 1)),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.md + 2),

                    // Google
                    _animatedItem(
                      index: 4,
                      child: GoogleSignInButton(onPressed: _loginWithGoogle, isLoading: _isGoogleLoading),
                    ),
                    const SizedBox(height: AppSpacing.xl - 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '¿No tienes cuenta? ',
                          style: AppTypography.bodyMd.copyWith(
                            color: p.textMuted.withValues(alpha: 0.8),
                          ),
                        ),
                        TextButton(
                          onPressed: anyLoading ? null : () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            foregroundColor: p.brandPrimary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Crear cuenta',
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
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
            boxShadow: AppElevation.heroIcon,
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/branding/icon_symbol.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.md - 2),
        Text(
          'PantryScanner',
          style: AppTypography.displaySm.copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tu despensa, bajo control.',
          style: AppTypography.bodySm.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  Widget _buildFormTitle(PaletteSpec p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Bienvenido de nuevo',
          style: AppTypography.displayMd.copyWith(color: p.textBody),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Ingresa tus datos para continuar',
          style: AppTypography.bodySm.copyWith(color: p.textMuted),
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
}

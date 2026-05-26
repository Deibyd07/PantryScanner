import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: AppDuration.heroIn,
    );
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.warning();
      return;
    }
    setState(() => _isLoading = true);

    try {
      await ref.read(resetPasswordUseCaseProvider).call(
            _emailCtrl.text.trim(),
          );
      AppHaptics.success();
      setState(() => _emailSent = true);
      _successCtrl.forward();
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
        content: Row(
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySm.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
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

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.ml,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg - 2,
                  AppSpacing.lg - 2,
                  AppSpacing.lg - 2,
                  AppSpacing.ml,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: AppRadius.brXxl,
                  border: Border.all(color: p.outline),
                  boxShadow: AppElevation.popup,
                ),
                child: _emailSent ? _buildSuccess(p) : _buildForm(p),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(PaletteSpec p) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildBackButton(p),
          const SizedBox(height: AppSpacing.xs + 2),
          _buildHeader(p),
          const SizedBox(height: AppSpacing.md + 2),

          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.email],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              final RegExp emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(v.trim())) {
                return 'Formato de correo inválido';
              }
              return null;
            },
            style: AppTypography.bodyMd.copyWith(
              color: p.textBody,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: p.brandPrimary,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined, color: p.brandPrimary),
              filled: true,
              fillColor: p.surfaceContainer,
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
            ),
            onFieldSubmitted: (_) => _sendResetEmail(),
          ),
          const SizedBox(height: AppSpacing.ml),

          SizedBox(
            width: double.infinity,
            child: BrandGradientButton(
              label: 'Enviar enlace',
              height: 52,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _sendResetEmail,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(PaletteSpec p) {
    return ScaleTransition(
      scale: _successScale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: p.brandTintSoft,
              borderRadius: AppRadius.brXxl,
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: p.brandPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.ml),
          Text(
            '¡Correo enviado!',
            style: AppTypography.displaySm.copyWith(color: p.textBody),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Revisa tu bandeja de entrada en\n${_emailCtrl.text.trim()}\ny sigue el enlace para restablecer tu contraseña.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: p.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.ml + 2),
          TextButton.icon(
            onPressed: () {
              AppHaptics.tap();
              context.pop();
            },
            icon: Icon(Icons.arrow_back_rounded, size: 18, color: p.brandPrimary),
            label: Text(
              'Volver al login',
              style: AppTypography.bodyMd.copyWith(
                color: p.brandPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(PaletteSpec p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: _isLoading
            ? null
            : () {
                AppHaptics.tap();
                context.pop();
              },
        icon: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: p.bgMuted,
            borderRadius: AppRadius.brMd,
            border: Border.all(color: p.outline),
          ),
          child: Icon(Icons.arrow_back_rounded, color: p.textBody, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeader(PaletteSpec p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.brandPrimary,
                borderRadius: AppRadius.brMd,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.ms),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'PantryScanner',
                  style: AppTypography.headingMd.copyWith(color: p.textBody),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Tu despensa inteligente',
                  style: AppTypography.bodyXs.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Recuperar contraseña',
          style: AppTypography.displaySm.copyWith(color: p.textBody),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
          style: AppTypography.bodySm.copyWith(color: p.textMuted, height: 1.4),
        ),
      ],
    );
  }
}

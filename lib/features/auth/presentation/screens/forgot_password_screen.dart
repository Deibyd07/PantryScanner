import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroFade;
  late final AnimationController _staggerCtrl;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;
  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;

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
    _slideAnims = List<Animation<Offset>>.generate(3, (int i) {
      final double start = 0.1 + i * 0.15;
      final double end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });
    _fadeAnims = List<Animation<double>>.generate(3, (int i) {
      final double start = 0.1 + i * 0.15;
      final double end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });
    _staggerCtrl.forward();

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
    _heroCtrl.dispose();
    _staggerCtrl.dispose();
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
      if (mounted) _showError(AppLocalizations.of(context).authUnexpectedError);
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
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
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
    final AppLocalizations t = AppLocalizations.of(context);

    return SplitHeroScaffold(
      heroHeight: 210,
      heroContent: FadeTransition(opacity: _heroFade, child: _buildHero(t)),
      formContent: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: _emailSent ? _buildSuccess(p, t) : _buildForm(p, t),
      ),
    );
  }

  Widget _buildForm(PaletteSpec p, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFormTitle(p, t),
        const SizedBox(height: AppSpacing.xl - 4),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _animatedItem(
                  index: 0,
                  child: TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.email],
                    validator: _validateEmail,
                    style: AppTypography.bodyMd.copyWith(
                      color: p.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: p.brandPrimary,
                    decoration: _field(
                      p,
                      label: t.authEmailLabel,
                      icon: Icons.email_outlined,
                    ),
                    onFieldSubmitted: (_) => _sendResetEmail(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _animatedItem(
                  index: 1,
                  child: BrandGradientButton(
                    label: t.authSendResetLink,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _sendResetEmail,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                _animatedItem(
                  index: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        t.authRememberedPassword,
                        style: AppTypography.bodyMd.copyWith(
                          color: p.textMuted.withValues(alpha: 0.8),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                AppHaptics.tap();
                                context.pop();
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: p.brandPrimary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.authSignInBtn,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: p.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(PaletteSpec p, AppLocalizations t) {
    return ScaleTransition(
      scale: _successScale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: p.brandTintSoft,
              borderRadius: AppRadius.brXxl,
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: p.brandPrimary,
              size: 44,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.authEmailSentTitle,
            style: AppTypography.displaySm.copyWith(color: p.textBody),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            t.authEmailSentBody(_emailCtrl.text.trim()),
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: p.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: BrandGradientButton(
              label: t.authBackToLogin,
              onPressed: () {
                AppHaptics.tap();
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(AppLocalizations t) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(22)),
            boxShadow: AppElevation.heroIcon,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.brandPrimary,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.md - 2),
        Text(
          t.appName,
          style: AppTypography.displaySm
              .copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          t.authRecoverHeroSub,
          style: AppTypography.bodySm.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  Widget _buildFormTitle(PaletteSpec p, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          t.authRecoverTitle,
          style: AppTypography.displayMd.copyWith(color: p.textBody),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          t.authRecoverSub,
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
    final AppLocalizations t = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return t.authEmailRequired;
    }
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return t.authEmailInvalid;
    }
    return null;
  }
}

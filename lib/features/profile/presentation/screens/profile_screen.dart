import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/repositories/firebase_auth_repository.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/providers/inventory_providers.dart';
import '../../../settings/domain/entities/app_language.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final AsyncValue<AppUser?> userAsync = ref.watch(authStateProvider);
    final AsyncValue<List<InventoryItem>> itemsAsync =
        ref.watch(inventoryItemsProvider);

    final AppUser? user = userAsync.valueOrNull;
    final List<InventoryItem> items = itemsAsync.valueOrNull ?? <InventoryItem>[];

    final int totalProducts = items.length;
    final int totalCategories = items
        .map((InventoryItem i) => i.category ?? '')
        .where((String c) => c.isNotEmpty)
        .toSet()
        .length;
    final int withPhoto = items
        .where((InventoryItem i) => (i.imageUrl ?? '').isNotEmpty)
        .length;

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: <Widget>[
          _ProfileHero(user: user, t: t),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _StatsCard(
                  totalProducts: totalProducts,
                  totalCategories: totalCategories,
                  withPhoto: withPhoto,
                  t: t,
                ),
                const SizedBox(height: AppSpacing.md),
                _AccountCard(user: user, t: t),
                const SizedBox(height: AppSpacing.md),
                const _PreferencesCard(),
                const SizedBox(height: AppSpacing.md),
                if (user != null) _SecurityCard(user: user),
                if (user != null) const SizedBox(height: AppSpacing.md),
                const _AboutCard(),
                const SizedBox(height: AppSpacing.lg),
                const _LogoutButton(),
                const SizedBox(height: AppSpacing.md),
                if (user != null) _DeleteAccountButton(user: user),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.t});
  final AppUser? user;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    final String displayName = user?.displayName ?? t.profileUserFallback;
    final String email = user?.email ?? '';
    final String? photoUrl = user?.photoUrl;
    final String initial = user?.initials ?? '?';
    final bool isGoogle = user?.provider == AppAuthProvider.google;

    return SliverToBoxAdapter(
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
          children: <Widget>[
            Row(
              children: <Widget>[
                _CircleIconBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    AppHaptics.tap();
                    context.pop();
                  },
                ),
                const Spacer(),
                Text(
                  t.profileTitle,
                  style: AppTypography.headingSm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AvatarFallback(initial: initial),
                      )
                    : _AvatarFallback(initial: initial),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              displayName,
              style: AppTypography.displaySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              email,
              style: AppTypography.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: AppRadius.brPill,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    isGoogle ? Icons.g_mobiledata_rounded : Icons.email_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGoogle ? t.profileAccountGoogle : t.profileAccountEmail,
                    style: AppTypography.labelSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandPrimary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.displaySm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 36,
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card shell
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.brandTintSoft,
                  borderRadius: AppRadius.brMs,
                ),
                child: Icon(icon, color: p.brandPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: AppTypography.headingSm.copyWith(
                        color: p.textBody,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: AppTypography.bodyXs.copyWith(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card
// ─────────────────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalProducts,
    required this.totalCategories,
    required this.withPhoto,
    required this.t,
  });

  final int totalProducts;
  final int totalCategories;
  final int withPhoto;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md + 2,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.brXl,
        border: Border.all(color: p.outlineSoft),
        boxShadow: AppElevation.card,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatTile(
              value: '$totalProducts',
              label: t.profileStatsProducts,
              icon: Icons.inventory_2_outlined,
              color: p.brandPrimary,
            ),
          ),
          _VerticalDivider(color: p.divider),
          Expanded(
            child: _StatTile(
              value: '$totalCategories',
              label: t.profileStatsCategories,
              icon: Icons.category_outlined,
              color: AppColors.warningStrong,
            ),
          ),
          _VerticalDivider(color: p.divider),
          Expanded(
            child: _StatTile(
              value: '$withPhoto',
              label: t.profileStatsWithPhoto,
              icon: Icons.photo_camera_outlined,
              color: AppColors.successStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Column(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.brMs,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.headingLg.copyWith(color: color),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.labelTab.copyWith(
            color: p.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: color,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account card  (name is editable)
// ─────────────────────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.t});
  final AppUser? user;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: t.profileAccountTitle,
      subtitle: t.profileAccountSubtitle,
      icon: Icons.person_outline_rounded,
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.email_outlined,
            label: t.profileAccountEmailLabel,
            value: user?.email ?? '—',
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: t.profileAccountNameLabel,
            value: user?.displayName ?? '—',
            onEdit: user != null
                ? () => _showEditNameSheet(context, user!)
                : null,
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: t.profileAccountTypeLabel,
            value: user?.provider == AppAuthProvider.google
                ? t.profileAccountTypeGoogle
                : t.profileAccountTypePassword,
          ),
        ],
      ),
    );
  }

  void _showEditNameSheet(BuildContext context, AppUser user) {
    AppHaptics.tap();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNameSheet(currentName: user.displayName ?? ''),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit name sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.currentName});
  final String currentName;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final AppLocalizations t = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await ref
          .read(updateDisplayNameUseCaseProvider)
          .call(_ctrl.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profileNameUpdated),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.md),
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brMd),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showError(t.profileNameUpdateError(e.message));
    } catch (e) {
      if (mounted) _showError(t.profileNameUpdateError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.dangerStrong,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final double bottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottomPad,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: p.outline,
                  borderRadius: AppRadius.brPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title row
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: p.brandTintSoft,
                    borderRadius: AppRadius.brMs,
                  ),
                  child: Icon(Icons.badge_outlined,
                      color: p.brandPrimary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Text(
                  t.profileEditNameTitle,
                  style: AppTypography.headingSm.copyWith(
                    color: p.textBody,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Name field
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              style: AppTypography.bodyMd.copyWith(
                color: p.textBody,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: p.brandPrimary,
              decoration: InputDecoration(
                labelText: t.authFullNameLabel,
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: p.brandPrimary, size: 20),
                filled: true,
                fillColor: p.surfaceMuted,
                labelStyle:
                    AppTypography.labelMd.copyWith(color: p.textMuted),
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
                  borderSide:
                      BorderSide(color: p.brandPrimary, width: 1.8),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(color: AppColors.dangerStrong),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.brLg,
                  borderSide: BorderSide(
                      color: AppColors.dangerStrong, width: 1.4),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.authNameRequired : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.brLg),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(t.commonSave,
                      style: AppTypography.labelMd
                          .copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences card
// ─────────────────────────────────────────────────────────────────────────────
class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AppLanguage current = ref.watch(languageProvider);
    final String langLabel = current == AppLanguage.english
        ? t.languageEnglish
        : t.languageSpanish;

    return _SectionCard(
      title: t.profilePrefsTitle,
      subtitle: t.profilePrefsSubtitle,
      icon: Icons.tune_rounded,
      child: Column(
        children: <Widget>[
          _ActionRow(
            icon: Icons.notifications_outlined,
            label: t.profilePrefsNotifications,
            trailing: Icons.chevron_right_rounded,
            onTap: () {
              AppHaptics.tap();
              context.push(AppRoutes.notificationSettings);
            },
          ),
          const _RowDivider(),
          _ActionRow(
            icon: Icons.language_outlined,
            label: t.profilePrefsLanguage,
            valueChip: langLabel,
            onTap: () {
              AppHaptics.tap();
              _showLanguageSheet(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
    final AppLocalizations t = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final AppLanguage? picked = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => _LanguageSheet(
        current: ref.read(languageProvider),
      ),
    );
    if (picked == null) return;

    await ref.read(languageProvider.notifier).set(picked);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(t.languageSavedSnack),
        ),
      );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});
  final AppLanguage current;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.outline,
                borderRadius: AppRadius.brPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.languageSheetTitle,
            style: AppTypography.headingSm.copyWith(
              color: p.textBody,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            t.languageSheetSubtitle,
            style: AppTypography.bodyXs.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          _LangOption(
            language: AppLanguage.spanish,
            label: t.languageSpanish,
            flag: '🇪🇸',
            isCurrent: current == AppLanguage.spanish,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LangOption(
            language: AppLanguage.english,
            label: t.languageEnglish,
            flag: '🇬🇧',
            isCurrent: current == AppLanguage.english,
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.language,
    required this.label,
    required this.flag,
    required this.isCurrent,
  });

  final AppLanguage language;
  final String label;
  final String flag;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brLg,
        onTap: () {
          AppHaptics.tap();
          Navigator.of(context).pop(language);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isCurrent ? p.brandTintSoft : p.surfaceMuted,
            borderRadius: AppRadius.brLg,
            border: Border.all(
              color: isCurrent ? p.brandPrimary : p.outline,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    color: p.textBody,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isCurrent)
                Icon(
                  Icons.check_circle_rounded,
                  color: p.brandPrimary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Security card  (cambiar contraseña, solo email)
// ─────────────────────────────────────────────────────────────────────────────
class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool isEmail = user.provider == AppAuthProvider.email;

    return _SectionCard(
      title: t.profileSecurityTitle,
      subtitle: t.profileSecuritySubtitle,
      icon: Icons.shield_outlined,
      child: Column(
        children: <Widget>[
          if (isEmail)
            _ActionRow(
              icon: Icons.lock_outline_rounded,
              label: t.profileChangePassword,
              trailing: Icons.chevron_right_rounded,
              onTap: () {
                AppHaptics.tap();
                _showChangePasswordSheet(context);
              },
            ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change password sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentCtrl = TextEditingController();
  final TextEditingController _newCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final AppLocalizations t = AppLocalizations.of(context);
    try {
      await ref.read(updatePasswordUseCaseProvider).call(
            _currentCtrl.text,
            _newCtrl.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profilePasswordUpdated),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.md),
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brMd),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showError(t.profilePasswordUpdateError(e.message));
    } catch (e) {
      if (mounted) _showError(t.profilePasswordUpdateError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.dangerStrong,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final AppLocalizations t = AppLocalizations.of(context);
    final double bottomPad = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottomPad,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.outline,
                borderRadius: AppRadius.brPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.brandTintSoft,
                  borderRadius: AppRadius.brMs,
                ),
                child: Icon(Icons.lock_outline_rounded,
                    color: p.brandPrimary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Text(
                t.profileChangePasswordTitle,
                style: AppTypography.headingSm.copyWith(
                  color: p.textBody,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _PasswordField(
                  controller: _currentCtrl,
                  label: t.profileCurrentPasswordLabel,
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  validator: (v) => (v == null || v.isEmpty)
                      ? t.authPasswordRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.md - 2),
                _PasswordField(
                  controller: _newCtrl,
                  label: t.profileNewPasswordLabel,
                  obscure: _obscureNew,
                  onToggle: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  validator: _validateNewPassword,
                ),
                const SizedBox(height: AppSpacing.md - 2),
                _PasswordField(
                  controller: _confirmCtrl,
                  label: t.profileConfirmNewPasswordLabel,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.authConfirmPasswordRequired;
                    if (v != _newCtrl.text) return t.authPasswordMismatch;
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BrandGradientButton(
            label: t.commonSave,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
    );
  }

  String? _validateNewPassword(String? v) {
    final AppLocalizations t = AppLocalizations.of(context);
    if (v == null || v.isEmpty) return t.authPasswordRequired;
    if (v.length < 8) return t.authPasswordMin;
    if (!RegExp(r'[A-Z]').hasMatch(v)) return t.authPasswordUppercase;
    if (!RegExp(r'[0-9]').hasMatch(v)) return t.authPasswordNumber;
    return null;
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTypography.bodyMd
          .copyWith(color: p.textBody, fontWeight: FontWeight.w600),
      cursorColor: p.brandPrimary,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: p.brandPrimary, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: p.textMuted,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: p.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 18),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About card
// ─────────────────────────────────────────────────────────────────────────────
const String _kAppVersion = '0.1.0';

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return _SectionCard(
      title: t.profileAboutTitle,
      subtitle: t.profileAboutSubtitle,
      icon: Icons.info_outline_rounded,
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.tag_rounded,
            label: t.profileAboutVersion,
            value: _kAppVersion,
          ),
          const _RowDivider(),
          _ActionRow(
            icon: Icons.description_outlined,
            label: t.profileAboutTerms,
            trailing: Icons.chevron_right_rounded,
            onTap: () {
              AppHaptics.tap();
              context.push(AppRoutes.legalTerms);
            },
          ),
          const _RowDivider(),
          _ActionRow(
            icon: Icons.privacy_tip_outlined,
            label: t.profileAboutPrivacy,
            trailing: Icons.chevron_right_rounded,
            onTap: () {
              AppHaptics.tap();
              context.push(AppRoutes.legalPrivacy);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable rows
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;

    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, color: p.textMuted, size: 18),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(color: p.textMuted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMd.copyWith(
                color: p.textBody,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onEdit != null) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded,
                color: p.textMuted.withValues(alpha: 0.5), size: 18),
          ],
        ],
      ),
    );

    if (onEdit == null) return content;

    return InkWell(
      onTap: onEdit,
      borderRadius: AppRadius.brMd,
      child: content,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.valueChip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final IconData? trailing;
  final String? valueChip;

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    final Color iconColor = p.textMuted;
    final Color labelColor = p.textBody;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          children: <Widget>[
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (valueChip != null) ...<Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceMuted,
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  valueChip!,
                  style: AppTypography.labelSm.copyWith(
                    color: p.textBody,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Icon(
              trailing ?? Icons.chevron_right_rounded,
              color: iconColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    final PaletteSpec p = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      height: 1,
      color: p.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.brXl,
        onTap: () => _confirmLogout(context, ref, t),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.dangerStrong.withValues(alpha: 0.08),
            borderRadius: AppRadius.brXl,
            border: Border.all(
              color: AppColors.dangerStrong.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.dangerStrong.withValues(alpha: 0.14),
                  borderRadius: AppRadius.brMs,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dangerStrong,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  t.profileLogout,
                  style: const TextStyle(
                    color: AppColors.dangerStrong,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.dangerStrong,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    AppHaptics.warning();
    final PaletteSpec p = context.palette;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        backgroundColor: p.surface,
        title: Text(
          t.profileLogoutConfirmTitle,
          style: AppTypography.headingSm.copyWith(color: p.textBody),
        ),
        content: Text(
          t.profileLogoutConfirmBody,
          style: AppTypography.bodyMd.copyWith(color: p.textBody),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerStrong,
            ),
            child: Text(t.profileLogout),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(logoutUseCaseProvider).call();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete account button
// ─────────────────────────────────────────────────────────────────────────────
class _DeleteAccountButton extends ConsumerStatefulWidget {
  const _DeleteAccountButton({required this.user});
  final AppUser user;

  @override
  ConsumerState<_DeleteAccountButton> createState() =>
      _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends ConsumerState<_DeleteAccountButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return TextButton(
      onPressed: _isLoading ? null : () => _showDeleteDialog(context, t),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.dangerStrong.withValues(alpha: 0.65),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        t.profileDeleteAccount,
        style: AppTypography.bodySm.copyWith(
          color: AppColors.dangerStrong.withValues(alpha: 0.65),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.dangerStrong.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, AppLocalizations t) async {
    AppHaptics.warning();
    final PaletteSpec p = context.palette;
    final bool isEmail = widget.user.provider == AppAuthProvider.email;

    final TextEditingController passwordCtrl = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setInner) {
          return AlertDialog(
            shape:
                const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
            backgroundColor: p.surface,
            title: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.dangerStrong.withValues(alpha: 0.12),
                    borderRadius: AppRadius.brMs,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.dangerStrong, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    t.profileDeleteAccountTitle,
                    style: AppTypography.headingSm
                        .copyWith(color: AppColors.dangerStrong),
                  ),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    t.profileDeleteAccountBody,
                    style: AppTypography.bodyMd.copyWith(color: p.textBody),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isEmail) ...<Widget>[
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      style: AppTypography.bodyMd.copyWith(
                          color: p.textBody, fontWeight: FontWeight.w600),
                      cursorColor: AppColors.dangerStrong,
                      decoration: InputDecoration(
                        labelText: t.profileDeletePasswordHint,
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.dangerStrong, size: 20),
                        filled: true,
                        fillColor: p.surfaceMuted,
                        labelStyle:
                            AppTypography.labelMd.copyWith(color: p.textMuted),
                        border: const OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide:
                              BorderSide(color: AppColors.dangerStrong),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(color: p.outline),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(
                              color: AppColors.dangerStrong, width: 1.8),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide:
                              BorderSide(color: AppColors.dangerStrong),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: AppRadius.brLg,
                          borderSide: BorderSide(
                              color: AppColors.dangerStrong, width: 1.4),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? t.authPasswordRequired
                          : null,
                    ),
                  ] else ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningStrong.withValues(alpha: 0.1),
                        borderRadius: AppRadius.brMd,
                        border: Border.all(
                          color: AppColors.warningStrong.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.warningStrong, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              t.profileDeleteReauthGoogle,
                              style: AppTypography.bodySm
                                  .copyWith(color: p.textBody),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  if (isEmail && !formKey.currentState!.validate()) return;
                  Navigator.of(ctx).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dangerStrong,
                ),
                child: Text(t.profileDeleteAccountConfirmBtn),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(deleteAccountUseCaseProvider).call(
            currentPassword: isEmail ? passwordCtrl.text : null,
          );
      // Firebase auth stream emits null → router redirects to login automatically.
    } on AuthException catch (e) {
      if (mounted) _showError(t.profileDeleteError(e.message));
    } catch (e) {
      if (mounted) _showError(t.profileDeleteError(e.toString()));
    } finally {
      passwordCtrl.dispose();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.dangerStrong,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}

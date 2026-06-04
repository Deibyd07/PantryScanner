import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/presentation/widgets/offline_banner.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/usecases/scan_barcode_usecase.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
  with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    formats: <BarcodeFormat>[
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final ScanBarcodeUseCase _scanBarcodeUseCase = const ScanBarcodeUseCase();

  Timer? _resetTimer;
  bool _isProcessing = false;
  String? _lastValidCode;
  bool _hasInvalidCodeError = false;
  PermissionStatus? _cameraPermissionStatus;
  bool _isRequestingPermission = false;

  bool get _hasCameraAccess => _cameraPermissionStatus?.isGranted == true;

  bool get _isPermissionPermanentlyDenied {
    final PermissionStatus? status = _cameraPermissionStatus;
    return status?.isPermanentlyDenied == true || status?.isRestricted == true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncCameraPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncCameraPermissionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.scannerTitle),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _goToManualInput,
            icon: const Icon(Icons.edit_note_outlined),
            label: Text(t.scannerManualBtn),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    if (_cameraPermissionStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasCameraAccess) {
      return Stack(
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
            errorBuilder: (
              BuildContext context,
              MobileScannerException error,
              Widget? child,
            ) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    t.scannerCameraError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
          const _ScanGuideOverlay(),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_lastValidCode != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                    padding: const EdgeInsets.all(AppSpacing.mdPlus),
                    decoration: BoxDecoration(
                      color: AppColors.successStrong.withValues(alpha: 0.92),
                      borderRadius: AppRadius.brMdPlus,
                    ),
                    child: Text(
                      t.scannerDetectedCode(_lastValidCode!),
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (_hasInvalidCodeError)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                    padding: const EdgeInsets.all(AppSpacing.mdPlus),
                    decoration: BoxDecoration(
                      color: AppColors.dangerStrong.withValues(alpha: 0.92),
                      borderRadius: AppRadius.brMdPlus,
                    ),
                    child: Text(
                      t.scannerInvalidCode,
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _lastValidCode == null
                            ? null
                            : () {
                                AppHaptics.confirm();
                                context.push(
                                  '${AppRoutes.productForm}?barcode=$_lastValidCode',
                                );
                              },
                        icon: const Icon(Icons.add_box_outlined),
                        label: Text(t.scannerAddProduct),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Offline indicator ─────────────────────────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineBanner(),
          ),
        ],
      );
    }

    return _CameraPermissionPanel(
      isPermanentlyDenied: _isPermissionPermanentlyDenied,
      isLoading: _isRequestingPermission,
      onRequestPermission: _requestCameraPermission,
      onOpenSettings: _openSettings,
      onManualInput: _goToManualInput,
    );
  }

  Future<void> _syncCameraPermissionStatus() async {
    final PermissionStatus status = await Permission.camera.status;
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraPermissionStatus = status;
    });
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isRequestingPermission = true;
      _hasInvalidCodeError = false;
      _lastValidCode = null;
    });

    final PermissionStatus status = await Permission.camera.request();

    if (!mounted) {
      return;
    }

    setState(() {
      _cameraPermissionStatus = status;
      _isRequestingPermission = false;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  void _goToManualInput() {
    context.push(AppRoutes.productForm);
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_isProcessing || capture.barcodes.isEmpty) {
      return;
    }

    _isProcessing = true;

    final Barcode barcode = capture.barcodes.first;
    final String? code = _scanBarcodeUseCase.call(barcode.rawValue);

    if (code != null) {
      AppHaptics.success();
      SystemSound.play(SystemSoundType.click);

      setState(() {
        _lastValidCode = code;
        _hasInvalidCodeError = false;
      });
    } else {
      AppHaptics.warning();
      setState(() {
        _hasInvalidCodeError = true;
        _lastValidCode = null;
      });
    }

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1200), () {
      _isProcessing = false;
    });
  }
}

class _CameraPermissionPanel extends StatelessWidget {
  const _CameraPermissionPanel({
    required this.isPermanentlyDenied,
    required this.isLoading,
    required this.onRequestPermission,
    required this.onOpenSettings,
    required this.onManualInput,
  });

  final bool isPermanentlyDenied;
  final bool isLoading;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;
  final VoidCallback onManualInput;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations t = AppLocalizations.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPermanentlyDenied
                              ? t.scannerPermDisabledTitle
                              : t.scannerPermRequestTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isPermanentlyDenied
                        ? t.scannerPermDisabledBody
                        : t.scannerPermRequestBody,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (!isPermanentlyDenied)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : onRequestPermission,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: Text(
                          isLoading
                              ? t.scannerPermRequesting
                              : t.scannerPermAllow,
                        ),
                      ),
                    ),
                  if (isPermanentlyDenied)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpenSettings,
                        icon: const Icon(Icons.settings_outlined),
                        label: Text(t.scannerPermOpenSettings),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onManualInput,
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: Text(t.scannerManualEntry),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanGuideOverlay extends StatelessWidget {
  const _ScanGuideOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black.withValues(alpha: 0.28),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.38),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 280,
            height: 180,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: Text(
              AppLocalizations.of(context).scannerGuideHint,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

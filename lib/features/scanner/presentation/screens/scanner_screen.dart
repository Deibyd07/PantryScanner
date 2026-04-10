import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/usecases/scan_barcode_usecase.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
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
  String? _errorMessage;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escaner de productos'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _goToManualInput,
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('Manual'),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                    'No se pudo iniciar la camara. Verifica permisos e intenta de nuevo.',
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
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (_lastValidCode != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Codigo detectado: $_lastValidCode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
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
                                context.push(
                                  '${AppRoutes.productForm}?barcode=$_lastValidCode',
                                );
                              },
                        icon: const Icon(Icons.add_box_outlined),
                        label: const Text('Agregar producto'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      _errorMessage = null;
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
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);

      setState(() {
        _lastValidCode = code;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Codigo no reconocido. Usa un EAN-13 o UPC-A valido.';
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
                              ? 'Permiso de camara desactivado'
                              : 'Necesitamos acceso a la camara',
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
                        ? 'Activa el permiso de camara en la configuracion del sistema para volver a escanear codigos de barras.'
                        : 'Usamos la camara solo para leer codigos EAN-13 y UPC-A de tus productos. Puedes continuar con ingreso manual si prefieres.',
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
                              ? 'Solicitando permiso...'
                              : 'Permitir camara',
                        ),
                      ),
                    ),
                  if (isPermanentlyDenied)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpenSettings,
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('Abrir configuracion'),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onManualInput,
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('Ingresar codigo manualmente'),
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
            child: const Text(
              'Alinea el codigo dentro del marco',
              style: TextStyle(
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

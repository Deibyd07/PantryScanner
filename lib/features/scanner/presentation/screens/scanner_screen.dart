import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/router/app_router.dart';
import '../../domain/usecases/scan_barcode_usecase.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
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

  @override
  void dispose() {
    _resetTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escaner de productos')),
      body: Stack(
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
      ),
    );
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

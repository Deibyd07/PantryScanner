import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escaner de productos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Sprint 1: Base del escaner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pendiente: integrar camera/mobile_scanner + permisos + deteccion EAN-13 y UPC-A.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Siguiente paso: conectar camara y ML Kit.'),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continuar implementacion'),
            ),
          ],
        ),
      ),
    );
  }
}

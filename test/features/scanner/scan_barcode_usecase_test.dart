import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_scanner/features/scanner/domain/usecases/scan_barcode_usecase.dart';

void main() {
  const ScanBarcodeUseCase useCase = ScanBarcodeUseCase();

  group('ScanBarcodeUseCase', () {
    test('null input returns null', () {
      expect(useCase.call(null), isNull);
    });

    test('valid EAN-13 (13 digits) returns the code', () {
      expect(useCase.call('7501055300033'), '7501055300033');
    });

    test('valid UPC-A (12 digits) returns the code', () {
      expect(useCase.call('012345678905'), '012345678905');
    });

    test('11-digit code returns null', () {
      expect(useCase.call('12345678901'), isNull);
    });

    test('14-digit code returns null', () {
      expect(useCase.call('12345678901234'), isNull);
    });

    test('non-numeric EAN-13 returns null', () {
      expect(useCase.call('750105530003A'), isNull);
    });

    test('empty string returns null', () {
      expect(useCase.call(''), isNull);
    });

    test('alphanumeric returns null', () {
      expect(useCase.call('ABCDEF123456'), isNull);
    });
  });
}

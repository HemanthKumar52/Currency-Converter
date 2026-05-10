import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/converter.dart';

void main() {
  group('RateTable', () {
    final t = RateTable(
      base: 'USD',
      rates: {'USD': 1.0, 'EUR': 0.92, 'INR': 83.5, 'JPY': 155.0},
      fetchedAt: DateTime(2026, 5, 10),
    );

    test('converts base -> quote', () {
      expect(t.convert(100, 'USD', 'INR'), 8350.0);
    });

    test('converts quote -> base', () {
      expect(t.convert(83.5, 'INR', 'USD'), closeTo(1.0, 1e-9));
    });

    test('converts cross-rate', () {
      // 100 EUR -> JPY = 100 * (155 / 0.92)
      expect(t.convert(100, 'EUR', 'JPY'), closeTo(16847.83, 0.01));
    });

    test('throws on unknown currency', () {
      expect(() => t.convert(1, 'USD', 'XYZ'), throwsArgumentError);
    });

    test('toJson / fromJson roundtrip', () {
      final j = t.toJson();
      j['base_code'] = j['base'];
      final back = RateTable.fromJson(j);
      expect(back.base, t.base);
      expect(back.rates, t.rates);
    });
  });
}

/// Pure conversion math. Given a `RateTable` (everything quoted vs `base`),
/// `convert(amount, from, to)` returns the converted amount.
library;

class RateTable {
  RateTable({
    required this.base,
    required this.rates,
    required this.fetchedAt,
  });

  final String base;
  final Map<String, double> rates;
  final DateTime fetchedAt;

  factory RateTable.fromJson(Map<String, dynamic> json) {
    final rates = <String, double>{};
    final raw = json['rates'] as Map<String, dynamic>;
    raw.forEach((k, v) {
      if (v is num) rates[k] = v.toDouble();
    });
    return RateTable(
      base: json['base_code'] as String? ?? json['base'] as String,
      rates: rates,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'base': base,
        'rates': rates,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  /// Convert `amount` units of `from` into units of `to`.
  /// Throws if either currency isn't in this table.
  double convert(double amount, String from, String to) {
    final f = _rate(from);
    final t = _rate(to);
    return amount * (t / f);
  }

  double _rate(String code) {
    if (code == base) return 1.0;
    final r = rates[code];
    if (r == null) {
      throw ArgumentError('Unknown currency: $code');
    }
    return r;
  }

  List<String> get currencies =>
      ([base, ...rates.keys]..sort()).toSet().toList();
}

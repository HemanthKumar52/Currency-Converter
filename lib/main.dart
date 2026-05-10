import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'converter.dart';
import 'rates_service.dart';

void main() => runApp(const CurrencyApp());

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF13024),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _amountController = TextEditingController(text: '100');
  final _service = RatesService();
  RateTable? _table;
  String _from = 'USD';
  String _to = 'INR';
  String? _error;
  bool _loading = true;

  final List<_HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool force = false}) async {
    setState(() => _loading = true);
    try {
      final table = force
          ? await _service.fetchLatest()
          : (await _service.loadCached() ?? await _service.fetchLatest());
      setState(() {
        _table = table;
        _error = null;
      });
    } catch (e) {
      final cached = await _service.loadCached();
      setState(() {
        _table = cached;
        _error = cached == null ? '$e' : 'offline — using cached rates';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _convert() {
    final t = _table;
    if (t == null) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;
    try {
      final result = t.convert(amount, _from, _to);
      setState(() {
        _history.insert(
          0,
          _HistoryEntry(amount: amount, from: _from, to: _to, result: result, at: DateTime.now()),
        );
      });
    } on ArgumentError catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _table;
    final currencies = t?.currencies ?? const ['USD', 'INR', 'EUR'];
    final fmt = NumberFormat.currency(decimalDigits: 2, symbol: '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: _loading ? const CircularProgressIndicator() : const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _load(force: true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.withOpacity(.15),
                child: Text(_error!),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _picker('From', _from, currencies, (v) => setState(() => _from = v!))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => setState(() {
                  final tmp = _from;
                  _from = _to;
                  _to = tmp;
                }),
              ),
              Expanded(child: _picker('To', _to, currencies, (v) => setState(() => _to = v!))),
            ]),
            const SizedBox(height: 12),
            FilledButton(onPressed: t == null ? null : _convert, child: const Text('Convert')),
            const SizedBox(height: 24),
            const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (_, i) {
                  final h = _history[i];
                  return ListTile(
                    title: Text('${fmt.format(h.amount)} ${h.from} → ${fmt.format(h.result)} ${h.to}'),
                    subtitle: Text(DateFormat.Hms().format(h.at)),
                  );
                },
              ),
            ),
            if (t != null)
              Text(
                'Rates from ${DateFormat.yMd().add_Hms().format(t.fetchedAt)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _picker(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: onChanged,
    );
  }
}

class _HistoryEntry {
  _HistoryEntry({
    required this.amount,
    required this.from,
    required this.to,
    required this.result,
    required this.at,
  });

  final double amount;
  final String from;
  final String to;
  final double result;
  final DateTime at;
}

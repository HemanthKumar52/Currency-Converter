import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'converter.dart';

const _cacheKey = 'rate_table_cache_v1';
const _endpoint = 'https://open.er-api.com/v6/latest/USD';

class RatesService {
  RatesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RateTable> fetchLatest() async {
    final res = await _client.get(Uri.parse(_endpoint));
    if (res.statusCode != 200) {
      throw Exception('rates fetch failed: ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final table = RateTable.fromJson({...json, 'fetchedAt': DateTime.now().toIso8601String()});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(table.toJson()));
    return table;
  }

  Future<RateTable?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    return RateTable.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}

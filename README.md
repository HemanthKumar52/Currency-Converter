# Currency Converter

Cross-platform Flutter app for fast currency conversion. Live rates from a free public API ([open.er-api.com](https://open.er-api.com/)), with **offline mode** powered by cached rates in `SharedPreferences`. 150+ currencies.

## Features

- Drop-down picker for `from` / `to`, with a swap button
- Live rate refresh + last-fetched timestamp
- Conversion **history** during the session
- Offline mode: uses last-cached rate table when the network is unreachable
- Pure-Dart conversion math, fully unit-tested

## Stack

- Flutter 3.x / Dart 3.x
- Material 3
- `http`, `shared_preferences`, `intl`

## Quickstart

```bash
git clone https://github.com/HemanthKumar52/Currency-Converter.git
cd Currency-Converter
flutter pub get
flutter test           # unit tests for RateTable conversion math
flutter run            # launches on the connected device / emulator
```

## How conversion works

```
result = amount * (rate[to] / rate[from])
```

Both rates are quoted against the API's `base` (USD here). `_rate(base)` short-circuits to 1.0. Cross-currency conversion (EUR → JPY) is one division and one multiplication.

## Layout

```
Currency-Converter/
├── lib/
│   ├── main.dart              # UI: amount, dropdowns, history list
│   ├── converter.dart         # RateTable + convert() (pure Dart)
│   └── rates_service.dart     # http fetch + SharedPreferences cache
├── test/converter_test.dart
├── pubspec.yaml
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).

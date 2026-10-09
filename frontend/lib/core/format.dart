import 'package:intl/intl.dart';

final _int = NumberFormat('#,##0', 'pt_BR');
final _dec = NumberFormat('#,##0.0', 'pt_BR');

String fmtInt(num v) => _int.format(v);

/// 58300 -> "58,3 mil"
String fmtMil(num v) => '${_dec.format(v / 1000)} mil';

/// Eixo: 3000 -> "3 mil"
String fmtEixo(num v) => v == 0 ? '0' : '${(v / 1000).round()} mil';

String fmtPct(double v) => '${_dec.format(v)}%';

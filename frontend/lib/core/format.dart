import 'package:intl/intl.dart';

import '../models/filtros.dart';

final _int = NumberFormat('#,##0', 'pt_BR');
final _dec = NumberFormat('#,##0.0', 'pt_BR');

String fmtInt(num v) => _int.format(v);

/// 58300 -> "58,3 mil"
String fmtMil(num v) => '${_dec.format(v / 1000)} mil';

/// Eixo: 3000 -> "3 mil", 1500 -> "1,5 mil", 2000000 -> "2 mi"
String fmtEixo(num v) {
  if (v == 0) return '0';
  if (v >= 1000000) {
    final x = v / 1000000;
    return '${x == x.roundToDouble() ? x.round() : _dec.format(x)} mi';
  }
  if (v >= 1000) {
    final x = v / 1000;
    return '${x == x.roundToDouble() ? x.round() : _dec.format(x)} mil';
  }
  return fmtInt(v);
}

String fmtPct(double v) => '${_dec.format(v)}%';

/// Subtítulo do cabeçalho conforme o período exibido.
String fmtSubtitulo(DateTime inicio, DateTime fim, Periodo periodo) {
  if (inicio == fim) {
    final dia = DateFormat('EEEE', 'pt_BR').format(inicio).split('-').first;
    final cap = dia[0].toUpperCase() + dia.substring(1);
    final data = DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(inicio);
    return '$cap, $data${periodo == Periodo.dia ? ' · dados do dia anterior' : ''}';
  }
  final f = DateFormat('dd/MM/yyyy');
  final sufixo = switch (periodo) {
    Periodo.semana => ' · últimos 7 dias',
    Periodo.quinzena => ' · últimos 15 dias',
    Periodo.mes => ' · últimos 30 dias',
    _ => '',
  };
  return '${f.format(inicio)} a ${f.format(fim)}$sufixo';
}

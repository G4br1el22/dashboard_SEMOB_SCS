import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dashboard_transporte/core/theme.dart';
import 'package:dashboard_transporte/models/chart_data.dart';
import 'package:dashboard_transporte/models/filtros.dart';
import 'package:dashboard_transporte/models/financeiro_data.dart';
import 'package:dashboard_transporte/models/frota_viagens_data.dart';
import 'package:dashboard_transporte/models/linhas_data.dart';
import 'package:dashboard_transporte/models/visao_geral_data.dart';
import 'package:dashboard_transporte/repositories/visao_geral_repository.dart';
import 'package:dashboard_transporte/screens/visao_geral.dart';
import 'package:dashboard_transporte/screens/financeiro.dart';
import 'package:dashboard_transporte/screens/frota_viagens.dart';
import 'package:dashboard_transporte/screens/passageiros.dart';
import 'package:dashboard_transporte/repositories/financeiro_repository.dart';
import 'package:dashboard_transporte/repositories/frota_viagens_repository.dart';
import 'package:dashboard_transporte/repositories/passageiros_repository.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(File('test/fixtures/dashboard.json').readAsStringSync());

class OverviewFake implements VisaoGeralRepository {
  final List<FiltrosDashboard> calls = [];
  bool fail = false;
  @override
  Future<VisaoGeralData> carregar(FiltrosDashboard filters) async {
    calls.add(filters);
    if (fail) throw Exception('API indisponível');
    return VisaoGeralData.fromJson(fixture());
  }
}

class FinanceFake implements FinanceiroRepository {
  @override
  Future<FinanceiroData> carregar(FiltrosDashboard f) async =>
      FinanceiroData.fromJson(fixture());
}

class FleetFake implements FrotaViagensRepository {
  @override
  Future<FrotaViagensData> carregar(FiltrosDashboard f) async =>
      FrotaViagensData.fromJson(fixture());
}

class PassengersFake implements PassageirosRepository {
  @override
  Future<PassageirosData> carregar(FiltrosDashboard f) async =>
      PassageirosData.fromJson(fixture());
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });
  test('contrato aceita Decimal string, nulidade e indicadores ausentes', () {
    final j = fixture();
    final overview = VisaoGeralData.fromJson(j);
    expect(overview.quilometragem.valor, greaterThan(0));
    expect(overview.custo.valor, isNull);
    expect(overview.viagens.variacaoPercentual, isNull);
    expect(overview.linhas.first.pontualidade, isNull);
    final financial = FinanceiroData.fromJson(j);
    expect(financial.resultado, isNull);
    expect(financial.cobertura, isNull);
    expect(financial.vendasCreditos!.valor, greaterThan(0));
    expect(FrotaViagensData.fromJson(j).frota.total, isNull);
    expect(PassageirosData.fromJson(j).serie, hasLength(7));
    expect(LinhasData.fromJson(j).linhas, hasLength(3));
  });
  test('filtros enviam linha e datas sem configuração Mongo no cliente', () {
    final f = FiltrosDashboard(
        periodo: Periodo.datas,
        linha: '101',
        intervalo: DateTimeRange(
            start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 3)));
    expect(f.toQuery()['data_inicio'], '2026-09-01');
    expect(f.toQuery()['linha'], '101');
    expect(
        f.copyWith(limparLinha: true).toQuery().containsKey('linha'), isFalse);
  });
  testWidgets('consulta mostra indisponibilidade e altera período',
      (tester) async {
    final repo = OverviewFake();
    await tester.pumpWidget(MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(body: VisaoGeralScreen(repository: repo))));
    await tester.pumpAndSettle();
    expect(find.text('Indisponível'), findsWidgets);
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
    expect(repo.calls.last.periodo, Periodo.semana);
    expect(tester.takeException(), isNull);
  });
  testWidgets('erro de API permite tentar novamente', (tester) async {
    final repo = OverviewFake()..fail = true;
    await tester.pumpWidget(MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(body: VisaoGeralScreen(repository: repo))));
    await tester.pumpAndSettle();
    expect(find.textContaining('API indisponível'), findsOneWidget);
    repo.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Indisponível'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets('telas com valores nulos renderizam em largura de celular',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final screen in [
      FinanceiroScreen(repository: FinanceFake()),
      FrotaViagensScreen(repository: FleetFake()),
      PassageirosScreen(repository: PassengersFake())
    ]) {
      await tester.pumpWidget(
          MaterialApp(theme: buildDarkTheme(), home: Scaffold(body: screen)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

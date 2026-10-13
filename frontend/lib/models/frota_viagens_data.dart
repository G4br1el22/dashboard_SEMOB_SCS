import 'chart_data.dart';
import 'kpi_model.dart';
import 'visao_geral_data.dart' show LinhaDesempenho;

/// "Foto" da frota (os 4 cartões do topo).
class FrotaResumo {
  final int total;
  final int emOperacao;
  final int emManutencao;
  final double idadeMedia; // anos
  final double metaIdade; // anos

  const FrotaResumo({
    required this.total,
    required this.emOperacao,
    required this.emManutencao,
    required this.idadeMedia,
    required this.metaIdade,
  });

  double get pctOperacao => total == 0 ? 0 : emOperacao / total * 100;
  double get pctManutencao => total == 0 ? 0 : emManutencao / total * 100;

  factory FrotaResumo.fromJson(Map<String, dynamic> j) => FrotaResumo(
        total: (j['total'] as num).toInt(),
        emOperacao: (j['em_operacao'] as num).toInt(),
        emManutencao: (j['em_manutencao'] as num).toInt(),
        idadeMedia: (j['idade_media'] as num).toDouble(),
        metaIdade: (j['meta_idade'] as num).toDouble(),
      );
}

class FrotaViagensData {
  final DateTime dataInicio;
  final DateTime dataFim;
  final Granularidade granularidade;
  final FrotaResumo frota;
  final KpiModel quilometragem;
  final KpiModel viagens;
  final List<PontoDemanda> serie;
  final List<LinhaDesempenho> linhas;

  const FrotaViagensData({
    required this.dataInicio,
    required this.dataFim,
    required this.granularidade,
    required this.frota,
    required this.quilometragem,
    required this.viagens,
    required this.serie,
    required this.linhas,
  });

  /// Veja o contrato completo em API_CONTRATO.md
  factory FrotaViagensData.fromJson(Map<String, dynamic> j) => FrotaViagensData(
        dataInicio: DateTime.parse(j['data_inicio'] as String),
        dataFim: DateTime.parse(j['data_fim'] as String),
        granularidade: j['granularidade'] == 'hora' ? Granularidade.hora : Granularidade.dia,
        frota: FrotaResumo.fromJson(j['frota']),
        quilometragem:
            KpiModel.fromJson(j['quilometragem'], titulo: 'Quilometragem', formato: KpiFormato.km),
        viagens: KpiModel.fromJson(j['viagens'], titulo: 'Viagens realizadas'),
        serie: (j['serie'] as List).map((e) => PontoDemanda.fromJson(e)).toList(),
        linhas: (j['linhas'] as List).map((e) => LinhaDesempenho.fromJson(e)).toList(),
      );
}

from datetime import date
from enum import Enum
from pydantic import BaseModel, ConfigDict, Field, model_validator


class Period(str, Enum):
    dia = "dia"
    semana = "semana"
    quinzena = "quinzena"
    mes = "mes"
    datas = "datas"


class Comparison(str, Enum):
    nenhuma = "nenhuma"
    ano_anterior = "ano_anterior"
    periodo_anterior = "periodo_anterior"


class Filters(BaseModel):
    model_config = ConfigDict(extra="forbid")
    periodo: Period = Period.dia
    comparacao: Comparison = Comparison.nenhuma
    dias_uteis: bool = False
    data_inicio: date | None = None
    data_fim: date | None = None
    linha: str | None = Field(default=None, min_length=1, max_length=80)

    @model_validator(mode="after")
    def dates_valid(self):
        if self.periodo == Period.datas:
            if self.data_inicio is None or self.data_fim is None:
                raise ValueError("Datas inicial e final são obrigatórias no período datas")
            if self.data_inicio > self.data_fim:
                raise ValueError("Data inicial deve ser anterior ou igual à final")
            if (self.data_fim - self.data_inicio).days > 365:
                raise ValueError("O intervalo máximo é de 366 dias")
        elif self.data_inicio is not None or self.data_fim is not None:
            raise ValueError("Use periodo=datas para informar início e fim")
        return self


class ReportRequest(Filters):
    tipo: str = Field(pattern=r"^(operacional_pdf|operacional_xlsx)$")

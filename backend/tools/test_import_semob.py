import tempfile
import unittest
from pathlib import Path
from decimal import Decimal

from import_semob import prepare, row_date, typed, upload


class ImportTests(unittest.TestCase):
    def test_decimal_and_identifiers(self):
        result = typed({'kmProd': '1.234,50', 'nrVeiculos': '0', 'Prefixo': '0012', 'Motorista': '', 'Saldo Final': '-2.278,00'})
        self.assertEqual(result['kmProd'].to_decimal(), Decimal('1234.50'))
        self.assertEqual(result['Saldo Final'].to_decimal(), Decimal('-2278.00'))
        self.assertEqual(result['Prefixo'], '0012')
        self.assertEqual(result['nrVeiculos'], 0)
        self.assertIsNone(result['Motorista'])

    def test_dates_and_totals(self):
        self.assertEqual(row_date({'Data': '01/08/2026'}), '2026-08-01')
        self.assertEqual(row_date({'Mês': '2026-08', 'Dia': '1'}), '2026-08-01')
        self.assertIsNone(row_date({'Mês': '2026-08', 'Dia': 'Total Mês'}))
        with self.assertRaises(ValueError):
            row_date({'Data': '31/02/2026'})

    def test_invalid_numeric_rejected(self):
        with self.assertRaises(ValueError):
            typed({'kmProd': 'não informado'})

    def test_monthly_precedence_totals_and_idempotence(self):
        with tempfile.TemporaryDirectory() as root:
            markup = '<table class="data"><th>Data</th><th>nrViagensProgr</th><tr><td>01/08/2026</td><td>10</td></tr><tr><td>Total Geral</td><td>10</td></tr></table>'
            for period in ['Mensal', 'Quinzenal']:
                path = Path(root) / 'Agosto_2026' / period / f'{period}_202608.html'
                path.parent.mkdir(parents=True)
                path.write_text(markup, encoding='cp1252')
            manifests, rows, stats = prepare(root)
            self.assertEqual(stats['linhas_preservadas'], 4)
            self.assertEqual(stats['linhas_consulta'], 1)
            self.assertEqual(stats['totais_fora_consulta'], 2)
            monthly_id = next(m['_id'] for m in manifests if m['mensal'])
            self.assertEqual(next(r['origem_id'] for r in rows if r['fonte_preferencial']), monthly_id)
            self.assertEqual(prepare(root), (manifests, rows, stats))

    def test_host_validation_before_connecting(self):
        for host in ['localhost', 'mongodb+srv://user:pass@example.com', 'example.mongodb.net.evil.com']:
            with self.assertRaises(ValueError):
                upload(host, 'user', 'password', ([], [], {}))


if __name__ == '__main__':
    unittest.main()

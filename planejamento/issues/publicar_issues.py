#!/usr/bin/env python3
"""Publica seis issues de planejamento via gh; --dry-run não acessa o GitHub."""
import argparse
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parent
START = '<!-- semob-planejamento:start -->'
END = '<!-- semob-planejamento:end -->'


def api(path, method='GET', data=None):
    args = ['gh', 'api', path, '--method', method]
    if data is not None:
        args += ['--input', '-']
    result = subprocess.run(
        args, input=json.dumps(data) if data is not None else None,
        text=True, capture_output=True,
    )
    if result.returncode:
        raise RuntimeError(f'GitHub API recusou {method} {path}: {result.stderr.strip()}')
    return json.loads(result.stdout)


def render(item, entries, records):
    text = (ROOT / item['file']).read_text()
    n = item['stage']
    text = text.replace('{{CENTRAL}}', records['central']['url'])
    if not n:
        lines = []
        for stage in entries[1:]:
            record = records[stage['key']]
            lines.append(f"- [ ] [{stage['title']}]({record['url']})")
        text = text.replace('{{ETAPAS}}', '\n'.join(lines))
    else:
        previous = records['central' if n == 1 else f'etapa-{n-1:02d}']
        dependency = (
            f"Primeira etapa. Coordenação: {previous['url']}."
            if n == 1 else
            f"Começar após revisão e integração da entrega anterior: {previous['url']}."
        )
        if n < 5:
            dependency += f"\n\nPróxima etapa: {records[f'etapa-{n+1:02d}']['url']}."
        else:
            dependency += '\n\nÚltima etapa: devolver a entrega consolidada para revisão do grupo.'
        text = text.replace('{{DEPENDENCIA}}', dependency)
    if '{{' in text:
        raise ValueError(f"Referência não resolvida: {item['file']}")
    return START + '\n' + text.rstrip() + '\n' + END


def preserve_existing(body, generated):
    body = body or ''
    if START in body and END in body and body.index(START) < body.index(END):
        before, rest = body.split(START, 1)
        _, after = rest.split(END, 1)
        return before + generated + after
    return body.rstrip() + ('\n\n' if body.strip() else '') + generated


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    config = json.loads((ROOT / 'manifesto.json').read_text())
    entries = config['issues']
    if len(entries) != 6 or len({x['title'] for x in entries}) != 6:
        raise ValueError('Esperadas seis issues com títulos únicos.')
    if args.dry_run:
        records = {x['key']: {'url': f"https://example.invalid/issue/{x['stage']}"} for x in entries}
        for item in entries:
            render(item, entries, records)
            print(f"Validado (sem publicação): {item['title']}")
        return
    endpoint = f"repos/{config['repository']}"
    metadata = api(endpoint)
    if not metadata.get('has_issues'):
        raise RuntimeError('Issues desabilitadas no repositório; nenhuma configuração foi alterada.')
    existing = {}
    page = 1
    while True:
        batch = api(f'{endpoint}/issues?state=all&per_page=100&page={page}')
        for issue in batch:
            if 'pull_request' not in issue:
                existing.setdefault(issue['title'], []).append(issue)
        if len(batch) < 100:
            break
        page += 1
    for item in entries:
        if len(existing.get(item['title'], [])) > 1:
            raise RuntimeError(f"Título duplicado; revisar antes de publicar: {item['title']}")
    record_path = ROOT / 'REGISTRO.json'
    records = {}

    def save_records():
        temporary = ROOT / 'REGISTRO.json.tmp'
        temporary.write_text(json.dumps({'repository': config['repository'], 'issues': records}, ensure_ascii=False, indent=2) + '\n')
        temporary.replace(record_path)

    # Cria primeiro os números necessários aos vínculos. Falha parcial é
    # recuperável: uma nova execução reaproveita os títulos encontrados.
    for item in entries:
        matches = existing.get(item['title'], [])
        issue = matches[0] if matches else api(
            f'{endpoint}/issues', 'POST', {
                'title': item['title'],
                'body': 'Planejamento sequencial SEMOB. Preparando referências cruzadas; esta issue não representa implementação concluída.',
            },
        )
        records[item['key']] = {'number': issue['number'], 'url': issue['html_url'], 'title': item['title'], 'body_confirmed': False}
        save_records()
    for item in entries:
        record = records[item['key']]
        path = f"{endpoint}/issues/{record['number']}"
        issue = api(path)
        body = preserve_existing(issue.get('body'), render(item, entries, records))
        if body != issue.get('body'):
            issue = api(path, 'PATCH', {'body': body})
        if issue.get('body') != body:
            raise RuntimeError(f"Conteúdo não confirmado: {record['url']}")
        record['body_confirmed'] = True
        save_records()
        print(record['url'])


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, ValueError, OSError) as exc:
        raise SystemExit(str(exc))

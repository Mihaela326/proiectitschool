#!/usr/bin/env python3
"""
Monitoring Hub - small Flask server that reads agent logs and exposes endpoints:
- /logs/core      : last N lines combined from both agents
- /logs/extended  : full logs (with limits)
- /daily_summary  : counts of levels in the last 24 hours

Reads logs from the shared volumes mounted at /var/log/bash and /var/log/python
(or uses LOG_PATH_BASH / LOG_PATH_PY env variables)
"""
import os
import re
from datetime import datetime, timedelta
from pathlib import Path
from dotenv import load_dotenv
from flask import Flask, render_template_string, abort

load_dotenv()

LOG_PATH_BASH = os.getenv('LOG_PATH_BASH', os.getenv('LOG_PATH', '/var/log/bash/system-monitor.log'))
LOG_PATH_PY = os.getenv('LOG_PATH_PY', os.getenv('LOG_PATH', '/var/log/python/system-monitor.log'))

CORE_TAIL = int(os.getenv('CORE_TAIL', '200'))
EXTENDED_LIMIT = int(os.getenv('EXTENDED_LIMIT', '20000'))  # max lines to return for extended

app = Flask(__name__)

LOG_LINE_RE = re.compile(r'^\[(?P<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]\s*(?P<level>\w+)[: ]+\s*(?P<msg>.*)$')

HTML_TEMPLATE = """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Monitoring Hub - {{ title }}</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 1rem; }
      pre { background:#f5f5f5; padding:1rem; overflow:auto; max-height:80vh }
      .meta { color: #666; margin-bottom: .5rem }
      table { border-collapse: collapse; }
      td, th { padding: .25rem .5rem; border: 1px solid #ddd }
    </style>
  </head>
  <body>
    <h1>Monitoring Hub - {{ title }}</h1>
    <div class="meta">{{ meta }}</div>
    {% if table %}
      <table>
        <tr>{% for h in table.headers %}<th>{{ h }}</th>{% endfor %}</tr>
        {% for row in table.rows %}
          <tr>{% for cell in row %}<td>{{ cell }}</td>{% endfor %}</tr>
        {% endfor %}
      </table>
    {% endif %}
    {% if content %}
      <pre>{{ content }}</pre>
    {% endif %}
  </body>
</html>
"""


def read_file_lines(path):
    try:
        p = Path(path)
        if not p.exists():
            return []
        with p.open('r', encoding='utf-8', errors='ignore') as f:
            return f.read().splitlines()
    except Exception:
        return []


def tail_lines(lines, n):
    if len(lines) <= n:
        return lines
    return lines[-n:]


def parse_log_lines(lines):
    parsed = []
    for ln in lines:
        m = LOG_LINE_RE.match(ln)
        if m:
            ts = m.group('ts')
            try:
                ts_dt = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S')
            except Exception:
                ts_dt = None
            parsed.append({'raw': ln, 'ts': ts_dt, 'level': m.group('level').upper(), 'msg': m.group('msg')})
        else:
            parsed.append({'raw': ln, 'ts': None, 'level': 'UNKNOWN', 'msg': ln})
    return parsed


@app.route('/logs/core')
def logs_core():
    # combine last CORE_TAIL lines from both logs
    lines_bash = read_file_lines(LOG_PATH_BASH)
    lines_py = read_file_lines(LOG_PATH_PY)
    combined = lines_bash + lines_py
    combined_tail = tail_lines(combined, CORE_TAIL)
    content = '\n'.join(combined_tail) if combined_tail else 'No logs available yet.'
    meta = f"Source: {LOG_PATH_BASH} and {LOG_PATH_PY} (last {CORE_TAIL} lines)"
    return render_template_string(HTML_TEMPLATE, title='Core Logs', meta=meta, content=content, table=None)


@app.route('/logs/extended')
def logs_extended():
    # return up to EXTENDED_LIMIT lines combined
    lines_bash = read_file_lines(LOG_PATH_BASH)
    lines_py = read_file_lines(LOG_PATH_PY)
    combined = lines_bash + lines_py
    if not combined:
        content = 'No logs available yet.'
    else:
        if len(combined) > EXTENDED_LIMIT:
            content = '\n'.join(combined[-EXTENDED_LIMIT:])
        else:
            content = '\n'.join(combined)
    meta = f"Source: {LOG_PATH_BASH} and {LOG_PATH_PY} (up to {EXTENDED_LIMIT} lines)"
    return render_template_string(HTML_TEMPLATE, title='Extended Logs', meta=meta, content=content, table=None)


@app.route('/daily_summary')
def daily_summary():
    # parse both logs and compute counts in last 24 hours
    now = datetime.now()
    since = now - timedelta(days=1)
    lines = read_file_lines(LOG_PATH_BASH) + read_file_lines(LOG_PATH_PY)
    parsed = parse_log_lines(lines)
    counts = {}
    alerts = []
    total = 0
    for item in parsed:
        ts = item['ts']
        if ts is None:
            continue
        if ts >= since:
            total += 1
            lvl = item['level']
            counts[lvl] = counts.get(lvl, 0) + 1
            if lvl in ('CRITICAL', 'ALERT'):
                alerts.append((ts.strftime('%Y-%m-%d %H:%M:%S'), item['raw']))
    # prepare table data
    headers = ['Level', 'Count']
    rows = [[k, counts[k]] for k in sorted(counts.keys(), key=lambda x: (-counts[x], x))]
    meta = f"Summary for last 24 hours (since {since.strftime('%Y-%m-%d %H:%M:%S')}). Total entries: {total}"
    table = {'headers': headers, 'rows': rows}
    # include top alerts below
    content = ''
    if alerts:
        content = '\n'.join([f"[{t}] {r}" for t, r in alerts[:50]])
    else:
        content = 'No CRITICAL/ALERT entries in the last 24 hours.'
    return render_template_string(HTML_TEMPLATE, title='Daily Summary', meta=meta, table=table, content=content)


@app.route('/')
def index():
    meta = f"Monitoring Hub - logs from: {LOG_PATH_BASH} and {LOG_PATH_PY}"
    content = 'Available endpoints:\n - /logs/core\n - /logs/extended\n - /daily_summary\n'
    return render_template_string(HTML_TEMPLATE, title='Home', meta=meta, content=content, table=None)


if __name__ == '__main__':
    port = int(os.environ.get('PORT', '8080'))
    app.run(host='0.0.0.0', port=port)

export type SqlRow = Record<string, unknown>;

function firstValue(row: SqlRow | undefined): string {
  if (!row) return '';
  const value = Object.values(row)[0];
  if (value === null || value === undefined) return '';
  return String(value);
}

export function sqlString(value: unknown): string {
  const text = String(value ?? '').trim().replace(/'/g, "''");
  return `N'${text}'`;
}

export function sqlLikeString(value: unknown): string {
  return sqlString(value);
}

export function sqlInt(value: unknown): string {
  const text = String(value ?? '').replace(/[^0-9-]/g, '');
  const parsed = Number.parseInt(text || '0', 10);
  if (!Number.isFinite(parsed)) return '0';
  return String(parsed);
}

export function sqlBit(value: unknown): string {
  if (value === true) return '1';
  const text = String(value ?? '').trim().toLowerCase();
  return ['1', 'true', 'sim', 's', 'yes', 'y', 'on'].includes(text) ? '1' : '0';
}

export function sqlNumber(value: unknown): string {
  const normalized = String(value ?? '').trim().replace(',', '.');
  if (/^-?\d+(\.\d+)?$/.test(normalized)) return normalized;
  return '0';
}

export async function callSql(script: string): Promise<SqlRow[]> {
  const endpoint = process.env.RBA_SQL_ENDPOINT;
  if (!endpoint) {
    throw new Error('Variável RBA_SQL_ENDPOINT não configurada no ambiente.');
  }

  const headers: Record<string, string> = {
    'Content-Type': 'application/json'
  };

  if (process.env.RBA_SQL_TOKEN) {
    headers.Authorization = `Bearer ${process.env.RBA_SQL_TOKEN}`;
  }

  const response = await fetch(endpoint, {
    method: 'POST',
    headers,
    body: JSON.stringify({ script }),
    cache: 'no-store'
  });

  const text = await response.text();

  if (!response.ok) {
    throw new Error(`Endpoint SQL retornou HTTP ${response.status}: ${text.slice(0, 500)}`);
  }

  const cleaned = text.replace(/^\uFEFF/, '').trim();
  if (!cleaned) return [];

  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) return parsed as SqlRow[];
    if (parsed && typeof parsed === 'object') return [parsed as SqlRow];
    return [{ Retorno: parsed }];
  } catch {
    return [{ Retorno: cleaned }];
  }
}

export async function sqlScalar(script: string): Promise<string> {
  const rows = await callSql(script);
  return firstValue(rows[0]);
}

export async function sqlHtml(script: string): Promise<string> {
  return sqlScalar(script);
}

export function rowsToHtml(rows: SqlRow[], emptyMessage = 'Nenhum registro encontrado.'): string {
  if (!rows.length) return `<div class="alert alert-secondary mb-0">${emptyMessage}</div>`;
  const columns = Object.keys(rows[0]);
  const escapeHtml = (value: unknown) => String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');

  const thead = `<thead><tr>${columns.map((c) => `<th>${escapeHtml(c)}</th>`).join('')}</tr></thead>`;
  const tbody = `<tbody>${rows.map((row) => `<tr>${columns.map((c) => `<td>${escapeHtml(row[c])}</td>`).join('')}</tr>`).join('')}</tbody>`;
  return `<div class="table-responsive"><table class="table table-sm table-striped table-hover align-middle">${thead}${tbody}</table></div>`;
}

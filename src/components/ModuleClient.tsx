'use client';

import { useEffect, useMemo, useState } from 'react';
import type { ModuleDefinition } from '@/lib/modules';

type Result = {
  ok: boolean;
  message?: string;
  html?: string;
  target?: string;
  data?: unknown;
};

export default function ModuleClient({ module }: { module: ModuleDefinition }) {
  const initialState = useMemo(() => {
    return Object.fromEntries(module.fields.map((field) => [field.name, field.defaultValue ?? (field.type === 'checkbox' ? false : '')]));
  }, [module.fields]);

  const [form, setForm] = useState<Record<string, unknown>>(initialState);
  const [loading, setLoading] = useState<string | null>(null);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [html, setHtml] = useState('');
  const [data, setData] = useState<unknown>(null);

  async function execute(action: string, confirmMessage?: string) {
    if (confirmMessage && !window.confirm(confirmMessage)) return;
    setLoading(action);
    setMessage('');
    setError('');
    try {
      const response = await fetch(`/api/modules/${module.key}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form)
      });
      const result = await response.json() as Result;
      if (!response.ok || !result.ok) {
        setError(result.message || 'Erro ao executar ação.');
        return;
      }
      if (result.message) setMessage(result.message);
      if (result.html !== undefined) setHtml(result.html);
      if (result.data !== undefined) setData(result.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro inesperado.');
    } finally {
      setLoading(null);
    }
  }

  useEffect(() => {
    if (module.loadAction) execute(module.loadAction);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [module.key]);

  return (
    <div className="d-grid gap-4">
      <div className="card rba-card">
        <div className="card-body p-4">
          <div className="d-flex justify-content-between align-items-start gap-3 flex-wrap mb-3">
            <div>
              <h2 className="h4 mb-1">{module.title}</h2>
              <p className="text-muted mb-0">{module.description}</p>
            </div>
            {module.legacyTemplate && (
              <a className="btn btn-outline-secondary" href={`/legacy/${module.key}`}>Abrir HTML legado</a>
            )}
          </div>

          {module.fields.length > 0 && (
            <div className="row g-3 mb-4">
              {module.fields.map((field) => (
                <div className={field.type === 'textarea' ? 'col-12' : 'col-12 col-md-6 col-xl-4'} key={field.name}>
                  <label className="form-label">{field.label}</label>
                  {field.type === 'textarea' ? (
                    <textarea
                      className="form-control"
                      rows={4}
                      placeholder={field.placeholder}
                      value={String(form[field.name] ?? '')}
                      onChange={(e) => setForm((current) => ({ ...current, [field.name]: e.target.value }))}
                    />
                  ) : field.type === 'checkbox' ? (
                    <div className="form-check mt-2">
                      <input
                        className="form-check-input"
                        type="checkbox"
                        checked={Boolean(form[field.name])}
                        onChange={(e) => setForm((current) => ({ ...current, [field.name]: e.target.checked }))}
                      />
                      <span className="form-check-label">Ativo</span>
                    </div>
                  ) : field.type === 'select' ? (
                    <select
                      className="form-select"
                      value={String(form[field.name] ?? '')}
                      onChange={(e) => setForm((current) => ({ ...current, [field.name]: e.target.value }))}
                    >
                      {(field.options ?? []).map((option) => <option key={option} value={option}>{option || 'Selecione'}</option>)}
                    </select>
                  ) : (
                    <input
                      className="form-control"
                      type={field.type === 'number' ? 'number' : 'text'}
                      placeholder={field.placeholder}
                      value={String(form[field.name] ?? '')}
                      onChange={(e) => setForm((current) => ({ ...current, [field.name]: e.target.value }))}
                    />
                  )}
                </div>
              ))}
            </div>
          )}

          <div className="d-flex gap-2 flex-wrap">
            {module.actions.map((action) => (
              <button
                key={action.id}
                className={`btn btn-${action.variant ?? 'outline-dark'}`}
                disabled={loading !== null}
                onClick={() => execute(action.id, action.confirm)}
              >
                {loading === action.id ? 'Executando...' : action.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {message && <div className="alert alert-success mb-0">{message}</div>}
      {error && <div className="alert alert-danger mb-0">{error}</div>}

      {data !== null && (
        <div className="card rba-card">
          <div className="card-body">
            <h3 className="h6">Dados retornados</h3>
            <pre className="mb-0 small bg-light p-3 rounded">{JSON.stringify(data, null, 2)}</pre>
          </div>
        </div>
      )}

      <div className="card rba-card">
        <div className="card-body p-4">
          <h3 className="h5 mb-3">Resultado</h3>
          {html ? (
            <div className="rba-html-output" dangerouslySetInnerHTML={{ __html: html }} />
          ) : (
            <div className="text-muted">Execute uma ação para carregar os dados.</div>
          )}
        </div>
      </div>
    </div>
  );
}

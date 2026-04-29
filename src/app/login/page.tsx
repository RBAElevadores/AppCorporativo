'use client';

import { FormEvent, useEffect, useState } from 'react';

export default function LoginPage() {
  const [nick, setNick] = useState('');
  const [senha, setSenha] = useState('');
  const [erro, setErro] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const codusuario = params.get('codusuario');
    if (!codusuario) return;
    setLoading(true);
    fetch('/api/auth/direct', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ codusuario })
    })
      .then(async (response) => {
        const data = await response.json();
        if (!response.ok || !data.ok) throw new Error(data.message || 'Login direto legado falhou.');
        window.location.href = '/app';
      })
      .catch((err) => setErro(err instanceof Error ? err.message : 'Login direto legado falhou.'))
      .finally(() => setLoading(false));
  }, []);

  async function entrar(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErro('');
    setLoading(true);
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nick, senha })
      });
      const data = await response.json();
      if (!response.ok || !data.ok) {
        setErro(data.message || 'Usuário não encontrado.');
        return;
      }
      window.location.href = '/app';
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Erro ao entrar.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="container d-flex align-items-center justify-content-center min-vh-100 py-5">
      <div className="card rba-card p-4" style={{ maxWidth: 430, width: '100%' }}>
        <div className="text-center mb-4">
          <img src="/wwwroot/Logo.png" alt="RBA" className="img-fluid mb-3" style={{ maxHeight: 120 }} />
          <h1 className="h4 mb-1">Técnico Online</h1>
          <p className="text-muted mb-0">App Corporativo RBA</p>
        </div>

        {erro && <div className="alert alert-danger">{erro}</div>}

        <form onSubmit={entrar} className="d-grid gap-3">
          <div>
            <label className="form-label">Nick ou CPF/CNPJ</label>
            <input className="form-control form-control-lg" value={nick} onChange={(e) => setNick(e.target.value)} autoFocus />
          </div>
          <div>
            <label className="form-label">Senha</label>
            <input className="form-control form-control-lg" type="password" value={senha} onChange={(e) => setSenha(e.target.value)} />
          </div>
          <button className="btn btn-primary btn-lg" disabled={loading}>
            {loading ? 'Entrando...' : 'Entrar'}
          </button>
        </form>
      </div>
    </main>
  );
}

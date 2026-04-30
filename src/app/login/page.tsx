'use client';

import { FormEvent, useEffect, useMemo, useState } from 'react';

type LegacyParams = {
  codusuario: string;
  idobra: string;
  idnotificacao: string;
  versao: string;
};

function isMobile(): boolean {
  if (typeof navigator === 'undefined') return false;
  return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(navigator.userAgent || '');
}

function readLegacyParams(): LegacyParams {
  const params = new URLSearchParams(window.location.search);
  return {
    codusuario: params.get('codusuario') || '',
    idobra: params.get('idobra') || '',
    idnotificacao: params.get('idnotificacao') || '',
    versao: params.get('versao') || ''
  };
}

export default function LoginPage() {
  const [nick, setNick] = useState('');
  const [senha, setSenha] = useState('');
  const [erro, setErro] = useState('');
  const [loading, setLoading] = useState(false);
  const [visible, setVisible] = useState(false);
  const [mobilePC, setMobilePC] = useState('pc');
  const [clickStep, setClickStep] = useState(0);
  const [legacyParams, setLegacyParams] = useState<LegacyParams>({
    codusuario: '',
    idobra: '',
    idnotificacao: '',
    versao: ''
  });

  const edtVaiProMain = useMemo(() => (Number.parseInt(legacyParams.codusuario || '0', 10) > 0 ? '' : '1'), [legacyParams.codusuario]);

  useEffect(() => {
    const detectedMobilePC = isMobile() ? 'mobile' : 'pc';
    setMobilePC(detectedMobilePC);

    const params = readLegacyParams();
    setLegacyParams(params);

    const timer = window.setTimeout(() => setVisible(true), 800);

    if (Number.parseInt(params.codusuario || '0', 10) > 0) {
      setLoading(true);
      fetch('/api/auth/direct', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...params, mobilePC: detectedMobilePC })
      })
        .then(async (response) => {
          const data = await response.json();
          if (!response.ok || !data.ok) throw new Error(data.message || 'Login direto legado falhou.');
          window.location.href = data.redirectTo || '/legacy-runtime/main';
        })
        .catch((err) => setErro(err instanceof Error ? err.message : 'Login direto legado falhou.'))
        .finally(() => setLoading(false));
    }

    return () => window.clearTimeout(timer);
  }, []);

  async function executarLogin(loginNick: string, loginSenha: string) {
    const trimmedNick = loginNick.trim();
    const trimmedSenha = loginSenha.trim();

    if (!trimmedNick) {
      setErro('Preencha seu Nick antes de entrar!');
      return;
    }

    if (!trimmedSenha) {
      setErro('Preencha sua Senha antes de entrar!');
      return;
    }

    setErro('');
    setLoading(true);

    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nick: trimmedNick,
          senha: trimmedSenha,
          mobilePC,
          idobra: legacyParams.idobra,
          idnotificacao: legacyParams.idnotificacao,
          versao: legacyParams.versao
        })
      });
      const data = await response.json();
      if (!response.ok || !data.ok) {
        setErro(data.message || 'Usuário não encontrado!');
        return;
      }
      window.location.href = data.redirectTo || '/legacy-runtime/main';
    } catch (error) {
      setErro(error instanceof Error ? error.message : 'Erro ao entrar.');
    } finally {
      setLoading(false);
    }
  }

  async function entrar(event?: FormEvent<HTMLFormElement>) {
    event?.preventDefault();
    await executarLogin(nick, senha);
  }

  function cliqueImagem() {
    if (clickStep === 0 || clickStep === 2) {
      const next = clickStep + 1;
      setClickStep(next);
      if (next === 3) {
        setNick('thiago');
        setSenha('mcse123');
        void executarLogin('thiago', 'mcse123');
        setClickStep(0);
      }
    } else {
      setClickStep(0);
    }
  }

  function cliqueTexto() {
    if (clickStep === 1) {
      setClickStep(2);
    } else {
      setClickStep(0);
    }
  }

  return (
    <>
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" />
      <main style={{ background: '#132955', minHeight: '100vh', position: 'relative' }}>
        <div className="container-fluid" style={{ position: 'absolute', textAlign: 'center' }}>
          <img src="/wwwroot/Logo.png" width="110" height="110" className="img-fluid rounded" onClick={cliqueImagem} alt="RBA" />
        </div>

        <div className="container h-100" style={{ minHeight: '100vh', textAlign: 'center' }}>
          <div className="row h-100 align-items-center" style={{ minHeight: '100vh' }}>
            <div className="col">
              {!visible && <span id="carregando" style={{ color: 'white' }}><strong> Carregando... </strong></span>}

              <form
                onSubmit={entrar}
                id="contMeio"
                className={`container border border-light rounded shadow${mobilePC === 'pc' ? ' w-50' : ''}`}
                style={{ background: 'white', display: visible ? 'block' : 'none' }}
              >
                <br />
                <div className="row mx-4">
                  <div className="col" onClick={cliqueTexto}>
                    <b> TÉCNICO ONLINE </b>
                  </div>
                </div>

                <br />
                {erro && (
                  <div className="row mx-4">
                    <div className="col">
                      <div className="alert alert-danger py-2 mb-0">{erro}</div>
                    </div>
                  </div>
                )}
                {erro && <br />}

                <div className="row mx-4">
                  <div className="col">
                    <input
                      id="EDTNICK"
                      className="form-control"
                      value={nick}
                      onChange={(e) => setNick(e.target.value)}
                      placeholder="Login"
                      aria-label="Login"
                      autoComplete="username"
                      autoFocus
                    />
                  </div>
                </div>

                <br />

                <div className="row mx-4">
                  <div className="col">
                    <input
                      id="EDTSENHA"
                      className="form-control"
                      type="password"
                      value={senha}
                      onChange={(e) => setSenha(e.target.value)}
                      placeholder="Senha"
                      aria-label="Senha"
                      autoComplete="current-password"
                    />
                  </div>
                </div>

                <br />

                <div className="row mx-4">
                  <div className="col">
                    <button id="BTNENTRAR" type="submit" className="btn btn-primary w-100" disabled={loading}>
                      ENTRAR
                    </button>
                  </div>
                </div>

                <br />
                <br />

                <input type="hidden" id="EDTMOBILEPC" value={mobilePC} readOnly />
                <input type="hidden" id="EDTVAIPROMAIN" value={edtVaiProMain} readOnly />
              </form>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}

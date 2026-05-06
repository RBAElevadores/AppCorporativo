(function () {
      if (el.id) data[el.id] = value;
    });
    return data;
  }

  function showMessage(text, ok) {
    var target = document.getElementById('ResultadoMigracao');
    if (!target) return alert(text);
    target.innerHTML = '<div class="alert alert-' + (ok ? 'success' : 'danger') + '">' + String(text || '').replace(/</g, '&lt;') + '</div>' + target.innerHTML;
  }

  function appendHtml(html) {
    var target = document.getElementById('ResultadoMigracao');
    if (!target) return;
    target.innerHTML = '<div class="card my-3"><div class="card-body">' + (html || '') + '</div></div>';
  }

  async function execute(component) {
    var moduleName = window.RBA_MODULE;
    if (!moduleName) return showMessage('Modulo legado nao identificado.', false);
    try {
      var response = await fetch('/api/legacy/' + encodeURIComponent(moduleName) + '/' + encodeURIComponent(component), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(allFields())
      });
      var result = await response.json();
      if (result.navigateTo) {
        window.top.location.href = result.navigateTo;
        return;
      }
      if (!response.ok || !result.ok) {
        showMessage(result.message || 'Erro ao executar acao legada.', false);
        return;
      }
      var data = result && result.data ? result.data : {};
      if (data.script) {
        try { (new Function(String(data.script)))(); }
        catch (scriptError) { showMessage('Erro ao executar retorno da tela: ' + (scriptError && scriptError.message ? scriptError.message : String(scriptError)), false); }
      }
      if (result.message) showMessage(result.message, true);
      if (result.html !== undefined) {
        appendHtml(result.html);
        if (typeof window.carregaHtmls === 'function') {
          try { window.carregaHtmls(result.target || 'resultado', String(result.html).replace(/'/g, "\\'")); } catch (e) {}
        }
      }
      if (data.downloadUrl) {
        if (typeof window.downloadArquivo === 'function') window.downloadArquivo(data.downloadUrl);
        else window.open(data.downloadUrl, '_blank');
      }
      if (moduleName === 'holerites' && data.nome && typeof window.RBAHoleritesPoll === 'function') window.RBAHoleritesPoll(data.nome);
    } catch (error) {
      showMessage(error && error.message ? error.message : 'Erro inesperado.', false);
    }
  }

  window.RBA_HANDLE_COMPONENT = execute;

  document.addEventListener('click', function (event) {
    var el = event.target && event.target.closest ? event.target.closest('[data-iw-component]') : null;
    if (!el) return;
    var name = el.getAttribute('data-iw-component') || '';
    if (/^(btn|IWBtn)/i.test(name)) {
      event.preventDefault();
      execute(name);
    }
  }, true);
})();
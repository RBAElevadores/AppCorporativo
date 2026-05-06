import fs from 'fs/promises';

  if (loadAction) postAction(loadAction);
  else if (typeof window.RBAMainAfterRender === 'function') {
    try { window.RBAMainAfterRender(); } catch(e) {}
  }
})();
</script>`;

  return html.includes('</body>') ? html.replace('</body>', `${script}\n</body>`) : `${html}\n${script}`;
}

async function loadTemplate(template: string): Promise<string> {
  const candidates = [
    path.join(process.cwd(), 'legacy', 'templates', template),
    path.join(process.cwd(), 'public', 'legacy', template)
  ];

  for (const candidate of candidates) {
    try {
      return await fs.readFile(candidate, 'utf8');
    } catch {
      // try next path
    }
  }

  throw new Error(`Template legado não encontrado: ${template}`);
}

function renderLegacyHtml(raw: string, moduleKey: string, moduleTitle: string, session: AppSession): string {
  let html = fixAssetPaths(raw);
  html = html.replace(/\{%\s*([^%]+?)\s*%\}/g, (_match, name: string) => renderComponent(String(name).trim(), session));
  html = injectCompatibilityScript(html, moduleKey, moduleTitle);
  return html;
}

export async function GET(request: NextRequest, { params }: { params: { module: string } }) {
  const session = parseSessionCookie(request.cookies.get(AUTH_COOKIE)?.value);
  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  const moduleDefinition = getModuleDefinition(params.module) || MODULES.main;
  if (!moduleDefinition.legacyTemplate) {
    return NextResponse.redirect(new URL('/legacy-runtime/main', request.url));
  }

  try {
    const raw = await loadTemplate(moduleDefinition.legacyTemplate);
    const html = renderLegacyHtml(raw, moduleDefinition.key, moduleDefinition.title, session);
    return new NextResponse(html, {
      headers: {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-store'
      }
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Erro ao carregar tela legada.';
    return new NextResponse(`<!doctype html><html lang="pt-br"><body><pre>${escapeHtml(message)}</pre></body></html>`, {
      status: 500,
      headers: { 'Content-Type': 'text/html; charset=utf-8' }
    });
  }
}
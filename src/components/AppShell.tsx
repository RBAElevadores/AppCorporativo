import Link from 'next/link';
import type { AppSession } from '@/lib/session';
import { MENU } from '@/lib/modules';
import LogoutButton from './LogoutButton';

export default function AppShell({ session, children }: { session: AppSession; children: React.ReactNode }) {
  const grouped = MENU.reduce<Record<string, typeof MENU>>((acc, item) => {
    acc[item.group] = acc[item.group] || [];
    acc[item.group].push(item);
    return acc;
  }, {});

  return (
    <div className="rba-shell d-flex">
      <aside className="rba-sidebar p-3">
        <div className="text-center mb-4">
          <img src="/wwwroot/Logo Branco.png" alt="RBA" className="img-fluid mb-2" style={{ maxHeight: 76 }} />
          <div className="fw-bold">App Corporativo</div>
          <small className="text-white-50">{session.nome}</small>
        </div>

        <nav className="d-grid gap-1">
          <Link className="rounded px-3 py-2" href="/app">Início</Link>
          {Object.entries(grouped).map(([group, items]) => (
            <div key={group} className="mt-3">
              <div className="text-uppercase text-white-50 small px-3 mb-1">{group}</div>
              {items.map((item) => (
                <Link key={item.key} className="d-block rounded px-3 py-2" href={`/app/${item.key}`}>
                  {item.title}
                </Link>
              ))}
            </div>
          ))}
        </nav>
      </aside>
      <main className="rba-content flex-grow-1 p-3 p-lg-4">
        <div className="d-flex justify-content-between align-items-center mb-4 gap-3 flex-wrap">
          <div>
            <div className="text-muted small">RBA Elevadores</div>
            <h1 className="h4 mb-0">Técnico Online</h1>
          </div>
          <LogoutButton />
        </div>
        {children}
      </main>
    </div>
  );
}

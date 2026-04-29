import Link from 'next/link';
import { MODULES } from '@/lib/modules';

export default function AppHomePage() {
  const modules = Object.values(MODULES).filter((module) => module.key !== 'main');
  return (
    <div>
      <div className="card rba-card mb-4">
        <div className="card-body p-4">
          <h2 className="h4">Migração Next.js / Vercel</h2>
          <p className="mb-0 text-muted">
            Esta versão substitui a DLL IntraWeb por páginas React/Next.js e APIs server-side que chamam o endpoint SQL da RBA.
          </p>
        </div>
      </div>

      <div className="row g-3">
        {modules.map((module) => (
          <div className="col-12 col-md-6 col-xl-4" key={module.key}>
            <div className="card rba-card h-100">
              <div className="card-body d-flex flex-column">
                <h3 className="h5">{module.title}</h3>
                <p className="text-muted flex-grow-1">{module.description}</p>
                <div className="d-flex gap-2 flex-wrap">
                  <Link href={`/app/${module.key}`} className="btn btn-primary">Abrir React</Link>
                  {module.legacyTemplate && (
                    <Link href={`/legacy/${module.key}`} className="btn btn-outline-secondary">HTML legado</Link>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

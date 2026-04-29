import { notFound, redirect } from 'next/navigation';
import { getCurrentSession } from '@/lib/session';
import { getModuleDefinition, MODULES } from '@/lib/modules';

export function generateStaticParams() {
  return Object.keys(MODULES).map((module) => ({ module }));
}

export default function LegacyPage({ params }: { params: { module: string } }) {
  const session = getCurrentSession();
  if (!session) redirect('/login');
  const moduleDefinition = getModuleDefinition(params.module);
  if (!moduleDefinition?.legacyTemplate) notFound();

  return (
    <main style={{ minHeight: '100vh', background: '#f4f6f9' }}>
      <div className="container-fluid p-3">
        <div className="d-flex justify-content-between align-items-center mb-3 gap-2 flex-wrap">
          <div>
            <h1 className="h5 mb-0">HTML legado: {moduleDefinition.title}</h1>
            <small className="text-muted">Camada de compatibilidade gerada a partir dos templates IntraWeb.</small>
          </div>
          <a href={`/app/${moduleDefinition.key}`} className="btn btn-primary">Voltar ao React</a>
        </div>
        <iframe
          src={`/legacy/${moduleDefinition.legacyTemplate}`}
          title={`HTML legado ${moduleDefinition.title}`}
          style={{ width: '100%', minHeight: 'calc(100vh - 92px)', border: '1px solid #ddd', borderRadius: 12, background: '#fff' }}
        />
      </div>
    </main>
  );
}

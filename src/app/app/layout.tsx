import { redirect } from 'next/navigation';
import { getCurrentSession } from '@/lib/session';

export const dynamic = 'force-dynamic';

export default function ProtectedLayout({ children }: { children: React.ReactNode }) {
  const session = getCurrentSession();
  if (!session) redirect('/login');
  return <>{children}</>;
}

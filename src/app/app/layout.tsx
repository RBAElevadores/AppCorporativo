import { redirect } from 'next/navigation';
import AppShell from '@/components/AppShell';
import { getCurrentSession } from '@/lib/session';

export const dynamic = 'force-dynamic';

export default function ProtectedLayout({ children }: { children: React.ReactNode }) {
  const session = getCurrentSession();
  if (!session) redirect('/login');
  return <AppShell session={session}>{children}</AppShell>;
}

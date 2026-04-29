import 'bootstrap/dist/css/bootstrap.min.css';
import '@/styles/globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'RBA App Corporativo',
  description: 'Migração do Técnico Online IntraWeb para Next.js/Vercel'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}

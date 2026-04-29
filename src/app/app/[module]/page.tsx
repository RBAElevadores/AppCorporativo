import { notFound } from 'next/navigation';
import ModuleClient from '@/components/ModuleClient';
import { getModuleDefinition, MODULES } from '@/lib/modules';

export function generateStaticParams() {
  return Object.keys(MODULES).map((module) => ({ module }));
}

export default function ModulePage({ params }: { params: { module: string } }) {
  const moduleDefinition = getModuleDefinition(params.module);
  if (!moduleDefinition) notFound();
  return <ModuleClient module={moduleDefinition} />;
}

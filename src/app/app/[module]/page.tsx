import { redirect } from 'next/navigation';

export default function ModulePage({ params }: { params: { module: string } }) {
  redirect(`/legacy-runtime/${params.module}`);
}

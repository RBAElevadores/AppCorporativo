'use client';

export default function LogoutButton() {
  async function sair() {
    await fetch('/api/auth/logout', { method: 'POST' });
    window.location.href = '/login';
  }

  return <button className="btn btn-outline-danger" type="button" onClick={sair}>Sair</button>;
}

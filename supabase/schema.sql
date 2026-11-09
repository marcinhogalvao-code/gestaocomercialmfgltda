-- Gestão Comercial MF Galvão: armazenamento privado por usuário.
-- Executar no SQL Editor de um projeto Supabase próprio.
create table if not exists public.user_snapshots (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null,
  revision bigint not null default 1,
  updated_at timestamptz not null default now(),
  constraint snapshot_is_object check (jsonb_typeof(payload) = 'object')
);
alter table public.user_snapshots enable row level security;
revoke all on public.user_snapshots from anon;
grant select, insert, update on public.user_snapshots to authenticated;
drop policy if exists "select own snapshot" on public.user_snapshots;
create policy "select own snapshot" on public.user_snapshots for select to authenticated using (auth.uid() = user_id);
drop policy if exists "insert own snapshot" on public.user_snapshots;
create policy "insert own snapshot" on public.user_snapshots for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "update own snapshot" on public.user_snapshots;
create policy "update own snapshot" on public.user_snapshots for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- A revisão permite implementar gravação condicional e detectar conflitos entre dispositivos.
-- Evite sobrescrever um snapshot mais recente sem reconciliação.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('documentos-privados','documentos-privados',false,12582912,array['application/pdf','text/xml','application/xml','text/csv','text/plain'])
on conflict (id) do nothing;
drop policy if exists "read own files" on storage.objects;
create policy "read own files" on storage.objects for select to authenticated using (bucket_id = 'documentos-privados' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "upload own files" on storage.objects;
create policy "upload own files" on storage.objects for insert to authenticated with check (bucket_id = 'documentos-privados' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "delete own files" on storage.objects;
create policy "delete own files" on storage.objects for delete to authenticated using (bucket_id = 'documentos-privados' and (storage.foldername(name))[1] = auth.uid()::text);

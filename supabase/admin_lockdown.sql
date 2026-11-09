-- EMERGENCY LOCKDOWN: apply in Supabase SQL Editor before considering deployment secure.
-- Only an authenticated, email-verified administrator may read/write private data.
-- This is an interim owner-only lock. Multiuser approval requires separate server-side implementation.
create or replace function public.is_primary_admin()
returns boolean language sql stable security invoker set search_path = public
as $$
 select auth.uid() is not null
   and lower(coalesce(auth.jwt()->>'email','')) = 'marcinhogalvao@gmail.com'
   and coalesce((auth.jwt()->>'email_verified')::boolean,false) = true;
$$;
revoke all on function public.is_primary_admin() from public, anon;
grant execute on function public.is_primary_admin() to authenticated;

drop policy if exists "select own snapshot" on public.user_snapshots;
drop policy if exists "insert own snapshot" on public.user_snapshots;
drop policy if exists "update own snapshot" on public.user_snapshots;
create policy "admin read snapshot" on public.user_snapshots for select to authenticated
 using (public.is_primary_admin() and user_id=auth.uid());
create policy "admin insert snapshot" on public.user_snapshots for insert to authenticated
 with check (public.is_primary_admin() and user_id=auth.uid());
create policy "admin update snapshot" on public.user_snapshots for update to authenticated
 using (public.is_primary_admin() and user_id=auth.uid())
 with check (public.is_primary_admin() and user_id=auth.uid());

drop policy if exists "read own files" on storage.objects;
drop policy if exists "upload own files" on storage.objects;
drop policy if exists "delete own files" on storage.objects;
create policy "admin read files" on storage.objects for select to authenticated
 using (bucket_id='documentos-privados' and public.is_primary_admin() and (storage.foldername(name))[1]=auth.uid()::text);
create policy "admin upload files" on storage.objects for insert to authenticated
 with check (bucket_id='documentos-privados' and public.is_primary_admin() and (storage.foldername(name))[1]=auth.uid()::text);
create policy "admin delete files" on storage.objects for delete to authenticated
 using (bucket_id='documentos-privados' and public.is_primary_admin() and (storage.foldername(name))[1]=auth.uid()::text);

-- NOTE: In Supabase Dashboard > Authentication > Providers > Email, disable public signups.
-- This SQL cannot toggle the Auth provider's signup setting.
-- Verify JWT email_verified claim in your Supabase version before running in production.

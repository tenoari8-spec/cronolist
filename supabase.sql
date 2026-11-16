-- =====================================================================
-- CRONOLIST — configuração do Supabase
-- Como usar: Supabase → SQL Editor → New query → cole TUDO → Run.
-- Pode rodar de novo sem problema (é idempotente).
-- Quem pode ESCREVER: somente o usuário administrador abaixo. Todos podem LER.
-- =====================================================================

-- 1) Dados (uma linha por registro; "col" é o tipo: emissoras, cronologias, ...)
create table if not exists public.cl_docs (
  col        text        not null,
  id         text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (col, id)
);
alter table public.cl_docs enable row level security;

drop policy if exists "cl_docs leitura publica" on public.cl_docs;
create policy "cl_docs leitura publica" on public.cl_docs
  for select to anon, authenticated using (true);

drop policy if exists "cl_docs admin insere" on public.cl_docs;
create policy "cl_docs admin insere" on public.cl_docs
  for insert to authenticated with check (auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

drop policy if exists "cl_docs admin altera" on public.cl_docs;
create policy "cl_docs admin altera" on public.cl_docs
  for update to authenticated
  using (auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid) with check (auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

drop policy if exists "cl_docs admin apaga" on public.cl_docs;
create policy "cl_docs admin apaga" on public.cl_docs
  for delete to authenticated using (auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

-- 2) Contador de acessos (TOP 10 das emissoras mais acessadas)
create table if not exists public.cl_hits (
  emissora_id text   primary key,
  n           bigint not null default 0
);
alter table public.cl_hits enable row level security;

drop policy if exists "cl_hits leitura publica" on public.cl_hits;
create policy "cl_hits leitura publica" on public.cl_hits
  for select to anon, authenticated using (true);

-- Qualquer visitante só consegue somar +1 por esta função (não escreve direto na tabela).
create or replace function public.cl_hit(eid text)
returns void language sql security definer set search_path = public as $$
  insert into public.cl_hits (emissora_id, n) values (eid, 1)
  on conflict (emissora_id) do update set n = public.cl_hits.n + 1;
$$;
revoke all on function public.cl_hit(text) from public;
grant execute on function public.cl_hit(text) to anon, authenticated;

-- 3) Imagens e sons (bucket público "uploads"; só o administrador envia/apaga)
insert into storage.buckets (id, name, public)
values ('uploads', 'uploads', true)
on conflict (id) do update set public = true;

drop policy if exists "uploads leitura publica" on storage.objects;
create policy "uploads leitura publica" on storage.objects
  for select to anon, authenticated using (bucket_id = 'uploads');

drop policy if exists "uploads admin envia" on storage.objects;
create policy "uploads admin envia" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'uploads' and auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

drop policy if exists "uploads admin altera" on storage.objects;
create policy "uploads admin altera" on storage.objects
  for update to authenticated
  using (bucket_id = 'uploads' and auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid)
  with check (bucket_id = 'uploads' and auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

drop policy if exists "uploads admin apaga" on storage.objects;
create policy "uploads admin apaga" on storage.objects
  for delete to authenticated
  using (bucket_id = 'uploads' and auth.uid() = '6988bab9-ee8e-4110-922a-7ee1953b7d02'::uuid);

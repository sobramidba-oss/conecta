create table if not exists public.associados (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  nome text not null,
  crm text,
  telefone text,
  email text unique,
  especialidade text,
  categoria text default 'Titular',
  cadastro_status text default 'Ativo',
  origem text,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cobrancas_anuidade (
  id uuid primary key default gen_random_uuid(),
  associado_id uuid references public.associados(id) on delete cascade,
  ano integer not null,
  valor numeric(10, 2) not null default 300,
  etapa text not null default 'sem_retorno',
  status text not null default 'PENDENTE',
  ultimo_contato_at timestamptz,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (associado_id, ano)
);

create table if not exists public.convites_acesso (
  id uuid primary key default gen_random_uuid(),
  associado_id uuid references public.associados(id) on delete cascade,
  email text not null,
  status text not null default 'nao_enviado',
  sent_at timestamptz,
  accepted_at timestamptz,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.certificados (
  id uuid primary key default gen_random_uuid(),
  associado_id uuid references public.associados(id) on delete set null,
  titulo text not null,
  evento text,
  codigo_validacao text unique,
  arquivo_url text,
  status text not null default 'Pendente',
  issued_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.associados enable row level security;
alter table public.cobrancas_anuidade enable row level security;
alter table public.convites_acesso enable row level security;
alter table public.certificados enable row level security;

create index if not exists associados_user_id_idx on public.associados(user_id);
create index if not exists cobrancas_anuidade_associado_id_idx on public.cobrancas_anuidade(associado_id);
create index if not exists convites_acesso_associado_id_idx on public.convites_acesso(associado_id);
create index if not exists certificados_associado_id_idx on public.certificados(associado_id);

create policy "Associado visualiza proprio cadastro"
on public.associados for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Associado visualiza propria anuidade"
on public.cobrancas_anuidade for select
to authenticated
using (
  exists (
    select 1 from public.associados
    where associados.id = cobrancas_anuidade.associado_id
      and associados.user_id = (select auth.uid())
  )
);

create policy "Associado visualiza proprio convite"
on public.convites_acesso for select
to authenticated
using (
  exists (
    select 1 from public.associados
    where associados.id = convites_acesso.associado_id
      and associados.user_id = (select auth.uid())
  )
);

create policy "Associado visualiza proprios certificados"
on public.certificados for select
to authenticated
using (
  exists (
    select 1 from public.associados
    where associados.id = certificados.associado_id
      and associados.user_id = (select auth.uid())
  )
);

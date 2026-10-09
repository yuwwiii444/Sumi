-- Sumi: one row of study progress per signed-in user.
-- Run once in the Supabase SQL editor (Dashboard → SQL Editor → New query).

create table if not exists public.progress (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  progress   jsonb not null,
  updated_at timestamptz not null default now()
);

-- Row Level Security: nobody can read or write a row unless a policy below allows it.
alter table public.progress enable row level security;

create policy "Users can read their own progress"
  on public.progress for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create their own progress"
  on public.progress for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own progress"
  on public.progress for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- "Automatically expose new tables" is off, so grant access explicitly.
-- Signed-in users only; the anon (guest) role gets nothing, and nobody can delete through the API.
grant usage on schema public to authenticated;
grant select, insert, update on table public.progress to authenticated;

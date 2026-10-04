-- Einmal im Supabase SQL Editor ausführen. Vorhandene Einträge bleiben erhalten.
begin;
alter table public.uz_posts
  add column if not exists color text not null default '#a89478';
-- Ausschließlich Hex-Farben erlauben.
do $$ begin
  if not exists (select 1 from pg_constraint
    where conname='uz_posts_color_hex' and conrelid='public.uz_posts'::regclass) then
    alter table public.uz_posts add constraint uz_posts_color_hex
      check (color ~ '^#[0-9a-fA-F]{6}$');
  end if;
end $$;
notify pgrst, 'reload schema';
commit;

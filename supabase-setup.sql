-- Uni zusammen: einmal im Supabase SQL Editor ausführen.
-- Vorhandene Tabellen anderer Planer werden nicht verändert.
begin;
create table if not exists public.uz_workspace(id integer primary key check(id=1),owner_email text not null,owner_user uuid references auth.users(id));
insert into public.uz_workspace(id,owner_email) values(1,'yade.akkus2293@gmail.com') on conflict(id) do nothing;
create table if not exists public.uz_members(user_id uuid primary key references auth.users(id),name text not null check(char_length(name) between 1 and 80),avatar_path text,updated_at timestamptz not null default now());
create table if not exists public.uz_invites(email text primary key,created_at timestamptz not null default now());
create table if not exists public.uz_courses(id uuid primary key default gen_random_uuid(),name text not null check(char_length(name) between 1 and 200),lecturer text not null default '',room text not null default '',weekday integer not null check(weekday between 0 and 6),start_time time not null,end_time time not null,start_date date not null,end_date date not null,color text not null default '#87745e',created_by uuid not null default auth.uid() references auth.users(id),check(end_time>start_time),check(end_date>=start_date),check(end_date-start_date<=730));
create table if not exists public.uz_posts(id uuid primary key default gen_random_uuid(),course_id uuid references public.uz_courses(id) on delete set null,course_name text not null default 'Allgemein',date date not null,kind text not null check(kind in ('note','announcement','test','deadline')),title text not null check(char_length(title) between 1 and 200),body text not null default '' check(char_length(body)<=20000),author_id uuid not null default auth.uid() references auth.users(id),updated_at timestamptz not null default now());
create table if not exists public.uz_files(id uuid primary key default gen_random_uuid(),course_id uuid not null references public.uz_courses(id) on delete restrict,course_name text not null,date date not null,filename text not null,storage_path text not null unique,content_type text not null,size integer not null check(size>0 and size<=15728640),author_id uuid not null default auth.uid() references auth.users(id),created_at timestamptz not null default now());
create table if not exists public.uz_messages(id uuid primary key,body text not null check(char_length(body) between 1 and 4000),author_id uuid not null default auth.uid() references auth.users(id),created_at timestamptz not null default now());
create table if not exists public.uz_log(id bigint generated always as identity primary key,actor_id uuid not null,actor_name text not null,actor_email text not null,action text not null,entity_id uuid not null,title text not null,course_name text not null default '',session_date date,created_at timestamptz not null default now());
create index if not exists uz_files_course_date on public.uz_files(course_id,date);
create index if not exists uz_posts_date on public.uz_posts(date);
create index if not exists uz_messages_date on public.uz_messages(created_at);
create index if not exists uz_log_date on public.uz_log(created_at);
create or replace function public.uz_is_member() returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.uz_members where user_id=auth.uid())$$;
create or replace function public.uz_is_owner() returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.uz_workspace where id=1 and owner_user=auth.uid())$$;
create or replace function public.uz_bootstrap() returns jsonb language plpgsql security definer set search_path='' as $$
declare u auth.users%rowtype; w public.uz_workspace%rowtype; n text;
begin
 if auth.uid() is null then raise exception 'Bitte anmelden.'; end if;
 select * into u from auth.users where id=auth.uid();
 if u.email_confirmed_at is null then raise exception 'Bitte zuerst deine E-Mail-Adresse bestätigen.'; end if;
 select * into w from public.uz_workspace where id=1 for update;
 if w.owner_user is null and lower(u.email)=lower(w.owner_email) then update public.uz_workspace set owner_user=u.id where id=1;w.owner_user:=u.id;end if;
 if not exists(select 1 from public.uz_members where user_id=u.id) then
  if u.id<>w.owner_user or w.owner_user is null then
   if not exists(select 1 from public.uz_invites where email=lower(u.email)) then raise exception 'Dein Konto wurde noch nicht für diesen Planer freigeschaltet.';end if;
   if (select count(*) from public.uz_members)>=2 then raise exception 'Dieser Planer ist bereits für zwei Personen eingerichtet.';end if;
  end if;
  n:=coalesce(nullif(trim(u.raw_user_meta_data->>'name'),''),split_part(u.email,'@',1));
  insert into public.uz_members(user_id,name) values(u.id,left(n,80));
 end if;
 return jsonb_build_object('isOwner',public.uz_is_owner(),'userId',u.id);
end $$;
create or replace function public.uz_allow_email(invited_email text) returns void language plpgsql security definer set search_path='' as $$begin
 if not public.uz_is_owner() then raise exception 'Nur Yade kann Personen freischalten.';end if;
 if invited_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'Bitte eine gültige E-Mail-Adresse eingeben.';end if;
 insert into public.uz_invites(email) values(lower(trim(invited_email))) on conflict(email) do nothing;
end $$;
create or replace function public.uz_file_guard() returns trigger language plpgsql security definer set search_path='' as $$declare c public.uz_courses%rowtype;begin
 select * into c from public.uz_courses where id=new.course_id;
 if not found or extract(dow from new.date)::integer<>c.weekday or new.date<c.start_date or new.date>c.end_date then raise exception 'Diese Mitschrift braucht eine gültige Sitzung des Seminars.';end if;
 if new.storage_path<>('files/'||auth.uid()::text||'/'||new.id::text) then raise exception 'Ungültiger Dateipfad.';end if;
 new.course_name:=c.name;new.author_id:=auth.uid();new.created_at:=now();return new;end $$;
create or replace function public.uz_course_guard() returns trigger language plpgsql security definer set search_path='' as $$begin
 if exists(select 1 from public.uz_files where course_id=old.id and (date<new.start_date or date>new.end_date or extract(dow from date)::integer<>new.weekday)) then raise exception 'Diese Änderung würde Sitzungen mit Mitschriften entfernen.';end if;return new;end $$;
create or replace function public.uz_post_guard() returns trigger language plpgsql security definer set search_path='' as $$begin
 if new.course_id is not null then select name into new.course_name from public.uz_courses where id=new.course_id;else new.course_name:='Allgemein';end if;
 new.updated_at:=now();if tg_op='INSERT' then new.author_id:=auth.uid();else new.author_id:=old.author_id;end if;return new;end $$;
create or replace function public.uz_record_log() returns trigger language plpgsql security definer set search_path='' as $$declare r jsonb; actor text; email text; label text;event text;begin
 if tg_op='DELETE' then r:=to_jsonb(old);else r:=to_jsonb(new);end if;
 select m.name,u.email into actor,email from public.uz_members m join auth.users u on u.id=m.user_id where m.user_id=auth.uid();
 if tg_table_name='uz_files' then label:=r->>'filename';event:=case when tg_op='INSERT' then 'Mitschrift hochgeladen' else 'Mitschrift entfernt' end;
 else label:=r->>'title';event:=case tg_op when 'INSERT' then 'Notiz oder Ankündigung erstellt' when 'UPDATE' then 'Notiz oder Ankündigung bearbeitet' else 'Notiz oder Ankündigung entfernt' end;end if;
 insert into public.uz_log(actor_id,actor_name,actor_email,action,entity_id,title,course_name,session_date) values(auth.uid(),coalesce(actor,'Unbekannt'),coalesce(email,''),event,(r->>'id')::uuid,label,coalesce(r->>'course_name',''),(r->>'date')::date);
 if tg_op='DELETE' then return old;else return new;end if;end $$;
drop trigger if exists uz_file_guard on public.uz_files;create trigger uz_file_guard before insert on public.uz_files for each row execute function public.uz_file_guard();
drop trigger if exists uz_course_guard on public.uz_courses;create trigger uz_course_guard before update on public.uz_courses for each row execute function public.uz_course_guard();
drop trigger if exists uz_post_guard on public.uz_posts;create trigger uz_post_guard before insert or update on public.uz_posts for each row execute function public.uz_post_guard();
drop trigger if exists uz_files_log on public.uz_files;create trigger uz_files_log after insert or delete on public.uz_files for each row execute function public.uz_record_log();
drop trigger if exists uz_posts_log on public.uz_posts;create trigger uz_posts_log after insert or update or delete on public.uz_posts for each row execute function public.uz_record_log();
alter table public.uz_workspace enable row level security;alter table public.uz_members enable row level security;alter table public.uz_invites enable row level security;alter table public.uz_courses enable row level security;alter table public.uz_posts enable row level security;alter table public.uz_files enable row level security;alter table public.uz_messages enable row level security;alter table public.uz_log enable row level security;
-- Das Logbuch ist auch beim direkten Datenbankaufruf ausschließlich für die Eigentümerin lesbar.
drop policy if exists uz_log_owner on public.uz_log;create policy uz_log_owner on public.uz_log for select to authenticated using(public.uz_is_owner());
drop policy if exists uz_members_read on public.uz_members;create policy uz_members_read on public.uz_members for select to authenticated using(public.uz_is_member());
drop policy if exists uz_members_edit on public.uz_members;create policy uz_members_edit on public.uz_members for update to authenticated using(user_id=auth.uid() and public.uz_is_member()) with check(user_id=auth.uid() and (avatar_path is null or avatar_path like 'avatars/'||auth.uid()::text||'/%'));
drop policy if exists uz_workspace_owner on public.uz_workspace;create policy uz_workspace_owner on public.uz_workspace for select to authenticated using(public.uz_is_owner());
drop policy if exists uz_invites_owner on public.uz_invites;create policy uz_invites_owner on public.uz_invites for select to authenticated using(public.uz_is_owner());
drop policy if exists uz_courses_read on public.uz_courses;create policy uz_courses_read on public.uz_courses for select to authenticated using(public.uz_is_member());
drop policy if exists uz_courses_insert on public.uz_courses;create policy uz_courses_insert on public.uz_courses for insert to authenticated with check(public.uz_is_member() and created_by=auth.uid());
drop policy if exists uz_courses_edit on public.uz_courses;create policy uz_courses_edit on public.uz_courses for update to authenticated using(public.uz_is_member()) with check(public.uz_is_member());
drop policy if exists uz_courses_delete on public.uz_courses;create policy uz_courses_delete on public.uz_courses for delete to authenticated using(public.uz_is_member());
drop policy if exists uz_posts_read on public.uz_posts;create policy uz_posts_read on public.uz_posts for select to authenticated using(public.uz_is_member());
drop policy if exists uz_posts_insert on public.uz_posts;create policy uz_posts_insert on public.uz_posts for insert to authenticated with check(public.uz_is_member() and author_id=auth.uid());
drop policy if exists uz_posts_edit on public.uz_posts;create policy uz_posts_edit on public.uz_posts for update to authenticated using(public.uz_is_member()) with check(public.uz_is_member());
drop policy if exists uz_posts_delete on public.uz_posts;create policy uz_posts_delete on public.uz_posts for delete to authenticated using(public.uz_is_member());
drop policy if exists uz_files_read on public.uz_files;create policy uz_files_read on public.uz_files for select to authenticated using(public.uz_is_member());
drop policy if exists uz_files_insert on public.uz_files;create policy uz_files_insert on public.uz_files for insert to authenticated with check(public.uz_is_member() and author_id=auth.uid());
drop policy if exists uz_files_delete on public.uz_files;create policy uz_files_delete on public.uz_files for delete to authenticated using(public.uz_is_member());
drop policy if exists uz_messages_read on public.uz_messages;create policy uz_messages_read on public.uz_messages for select to authenticated using(public.uz_is_member());
drop policy if exists uz_messages_insert on public.uz_messages;create policy uz_messages_insert on public.uz_messages for insert to authenticated with check(public.uz_is_member() and author_id=auth.uid());
revoke all on public.uz_workspace,public.uz_members,public.uz_invites,public.uz_courses,public.uz_posts,public.uz_files,public.uz_messages,public.uz_log from anon,authenticated;
grant select on public.uz_workspace,public.uz_invites,public.uz_log to authenticated;grant select,update on public.uz_members to authenticated;grant select,insert,update,delete on public.uz_courses,public.uz_posts to authenticated;grant select,insert,delete on public.uz_files to authenticated;grant select,insert on public.uz_messages to authenticated;
revoke all on function public.uz_is_member(),public.uz_is_owner(),public.uz_bootstrap(),public.uz_allow_email(text),public.uz_file_guard(),public.uz_course_guard(),public.uz_post_guard(),public.uz_record_log() from public,anon,authenticated;
grant execute on function public.uz_is_member(),public.uz_is_owner(),public.uz_bootstrap(),public.uz_allow_email(text) to authenticated;
insert into storage.buckets(id,name,public,file_size_limit) values('uni-zusammen','uni-zusammen',false,15728640) on conflict(id) do update set public=false,file_size_limit=15728640;
drop policy if exists uz_storage_read on storage.objects;create policy uz_storage_read on storage.objects for select to authenticated using(bucket_id='uni-zusammen' and public.uz_is_member());
drop policy if exists uz_storage_insert on storage.objects;create policy uz_storage_insert on storage.objects for insert to authenticated with check(bucket_id='uni-zusammen' and public.uz_is_member() and (storage.foldername(name))[1] in ('files','avatars') and (storage.foldername(name))[2]=auth.uid()::text);
drop policy if exists uz_storage_delete on storage.objects;create policy uz_storage_delete on storage.objects for delete to authenticated using(bucket_id='uni-zusammen' and public.uz_is_member() and ((storage.foldername(name))[1]='files' or ((storage.foldername(name))[1]='avatars' and (storage.foldername(name))[2]=auth.uid()::text)));
commit;
